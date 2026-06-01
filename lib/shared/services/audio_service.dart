// lib/shared/services/audio_service.dart
// Versi debug — tambah banyak print untuk lacak masalah

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  AudioPlayer? _player;

  static const _prefKeyMusic = 'setting_music';

  bool _isInitialized = false;
  bool _isMusicEnabled = true;

  Timer? _fadeTimer;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isPlaying => _player?.playing ?? false;

  // ── Init tanpa play ───────────────────────────────────────────────────────
  Future<void> initWithoutPlay() async {
    debugPrint('[AudioService] initWithoutPlay() dipanggil');

    if (_isInitialized) {
      debugPrint('[AudioService] sudah init sebelumnya, skip');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicEnabled = prefs.getBool(_prefKeyMusic) ?? true;
      debugPrint('[AudioService] music enabled dari prefs: $_isMusicEnabled');

      _player = AudioPlayer();
      debugPrint('[AudioService] AudioPlayer dibuat');

      await _player!.setAsset('assets/audio/bgm_main.ogg');
      debugPrint('[AudioService] asset berhasil di-load');

      await _player!.setLoopMode(LoopMode.one);
      await _player!.setVolume(1.0);

      _isInitialized = true;
      debugPrint('[AudioService] initWithoutPlay SELESAI ✓');
    } catch (e, stack) {
      debugPrint('[AudioService] initWithoutPlay ERROR: $e');
      debugPrint('[AudioService] stack: $stack');
      _isInitialized = false;
    }
  }

  // ── Start BGM saat masuk AppShell ─────────────────────────────────────────
  Future<void> startBgm() async {
    debugPrint('[AudioService] startBgm() dipanggil');
    debugPrint('[AudioService]   _isInitialized: $_isInitialized');
    debugPrint('[AudioService]   _isMusicEnabled: $_isMusicEnabled');
    debugPrint('[AudioService]   _player null: ${_player == null}');
    debugPrint('[AudioService]   isPlaying: ${_player?.playing}');

    if (!_isMusicEnabled) {
      debugPrint('[AudioService] musik dimatikan user, skip');
      return;
    }

    // Jika belum init (misal fire-and-forget belum selesai), init dulu
    if (!_isInitialized || _player == null) {
      debugPrint('[AudioService] belum init, coba init sekarang...');
      await initWithoutPlay();
    }

    if (_player == null) {
      debugPrint('[AudioService] _player masih null setelah init, abort');
      return;
    }

    if (_player!.playing) {
      debugPrint('[AudioService] sudah playing, skip');
      return;
    }

    try {
      _cancelFade();
      await _fadeIn();
      debugPrint('[AudioService] startBgm SELESAI ✓');
    } catch (e) {
      debugPrint('[AudioService] startBgm ERROR: $e');
    }
  }

  // ── Stop BGM saat logout ──────────────────────────────────────────────────
  Future<void> stopBgm() async {
    debugPrint('[AudioService] stopBgm() dipanggil');
    if (_player == null || !_player!.playing) return;
    try {
      await _fadeOutAndPause(durationMs: 600);
    } catch (e) {
      debugPrint('[AudioService] stopBgm ERROR: $e');
    }
  }

  // ── Toggle dari Settings ──────────────────────────────────────────────────
  Future<void> setMusicEnabled(bool enabled) async {
    debugPrint('[AudioService] setMusicEnabled($enabled)');
    _isMusicEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyMusic, enabled);

    if (_player == null) return;

    if (enabled) {
      await _fadeIn();
    } else {
      await _fadeOutAndPause();
    }
  }

  // ── Resume setelah keluar quiz ────────────────────────────────────────────
  Future<void> resumeIfEnabled() async {
    debugPrint('[AudioService] resumeIfEnabled() dipanggil');
    if (!_isMusicEnabled || _player == null || _player!.playing) return;
    _cancelFade();
    await _fadeIn();
  }

  // ── Fade out saat masuk quiz ──────────────────────────────────────────────
  Future<void> fadeOutAndPause({int durationMs = 800}) async {
    debugPrint('[AudioService] fadeOutAndPause() dipanggil');
    if (_player == null || !_player!.playing) return;
    await _fadeOutAndPause(durationMs: durationMs);
  }

  Future<void> dispose() async {
    _cancelFade();
    await _player?.dispose();
    _player = null;
    _isInitialized = false;
  }

  // ── PRIVATE ───────────────────────────────────────────────────────────────
  Future<void> _fadeOutAndPause({int durationMs = 800}) async {
    _cancelFade();
    if (_player == null) return;

    const steps = 20;
    final stepDuration = Duration(milliseconds: durationMs ~/ steps);
    final startVolume = _player!.volume;
    final volumeStep = startVolume / steps;
    final completer = Completer<void>();
    int step = 0;

    _fadeTimer = Timer.periodic(stepDuration, (timer) async {
      step++;
      final newVolume = (_player!.volume - volumeStep).clamp(0.0, 1.0);
      await _player?.setVolume(newVolume);

      if (step >= steps || newVolume <= 0.0) {
        timer.cancel();
        _fadeTimer = null;
        await _player?.pause();
        await _player?.setVolume(1.0);
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  Future<void> _fadeIn({int durationMs = 800}) async {
    _cancelFade();
    if (_player == null) return;

    await _player!.setVolume(0.0);
    await _player!.play();
    debugPrint('[AudioService] _player.play() dipanggil');

    const steps = 20;
    final stepDuration = Duration(milliseconds: durationMs ~/ steps);
    const volumeStep = 1.0 / steps;

    _fadeTimer = Timer.periodic(stepDuration, (timer) async {
      final newVolume = ((_player?.volume ?? 0) + volumeStep).clamp(0.0, 1.0);
      await _player?.setVolume(newVolume);

      if (newVolume >= 1.0) {
        timer.cancel();
        _fadeTimer = null;
        debugPrint(
          '[AudioService] fade in selesai, volume: ${_player?.volume}',
        );
      }
    });
  }

  void _cancelFade() {
    _fadeTimer?.cancel();
    _fadeTimer = null;
  }
}
