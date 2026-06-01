// lib/shared/services/audio_service.dart
//
// FIXES:
// 1. isMusicEnabled dijadikan RxBool agar SettingsController bisa observe langsung
//    tanpa perlu membuat RxBool baru yang tidak terhubung.
//
// 2. Race condition setelah stop(): ditambahkan guard _isStopping flag dan
//    await Future.delayed kecil sebelum seek+play agar AudioPlayer punya waktu
//    transisi state dari playing→idle setelah stop().
//
// 3. startBgm() dipindahkan ke compute isolate-friendly: semua inisialisasi
//    berat (AudioSession, setAudioSource) tetap di initWithoutPlay(),
//    tapi startBgm() tidak lagi memanggil ulang initWithoutPlay() yang bisa
//    menyebabkan double-init dan frame skip.
//
// 4. LoopingAudioSource dengan count besar diganti menjadi
//    player.setLoopMode(LoopMode.one) yang lebih efisien dan tidak membuat
//    decoder idle di titik loop ke-N.

import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  AudioPlayer? _player;

  static const _prefKeyMusic = 'setting_music';
  static const _bgmAsset = 'assets/audio/bgm_main.mp3';

  bool _isInitialized = false;
  bool _isInitializing = false;

  // FIX 1: isMusicEnabled sekarang RxBool agar bisa di-observe langsung
  // oleh SettingsController tanpa perlu membuat wrapper baru.
  final RxBool isMusicEnabledRx = true.obs;

  bool get isMusicEnabled => isMusicEnabledRx.value;
  bool get isPlaying => _player?.playing ?? false;

  Timer? _fadeTimer;

  // FIX 2: Flag untuk mencegah _fadeIn berjalan saat stop masih berproses
  bool _isStopping = false;

  // ── Init tanpa play ───────────────────────────────────────────────────────
  Future<void> initWithoutPlay() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEnabled = prefs.getBool(_prefKeyMusic) ?? true;
      isMusicEnabledRx.value = savedEnabled;

      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.ambient,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.mixWithOthers,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.game,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        ),
      );

      _player = AudioPlayer();

      // FIX 4: Gunakan LoopMode.one bukan LoopingAudioSource(count: 100).
      // LoopMode.one memanfaatkan loop internal just_audio yang lebih
      // seamless — decoder tidak idle di titik loop ke-N.
      await _player!.setLoopMode(LoopMode.one);
      await _player!.setAudioSource(AudioSource.asset(_bgmAsset));
      await _player!.setVolume(1.0);

      _isInitialized = true;
      debugPrint('[Audio] init OK, duration: ${_player!.duration}');
    } catch (e) {
      debugPrint('[Audio] INIT ERROR: $e');
      _player?.dispose();
      _player = null;
      _isInitialized = false;
    } finally {
      _isInitializing = false;
    }
  }

  // ── Start BGM saat masuk AppShell ─────────────────────────────────────────
  Future<void> startBgm() async {
    debugPrint('[AudioService] startBgm()');

    if (!isMusicEnabledRx.value) return;

    // FIX 3: Jika belum init, init dulu — tapi ini sudah dipanggil
    // di SplashController, jadi cabang ini hanya fallback.
    if (!_isInitialized || _player == null) {
      await initWithoutPlay();
    }

    if (_player == null) {
      debugPrint('[AudioService] _player null setelah init, abort');
      return;
    }

    if (_player!.playing) return;

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
    debugPrint('[AudioService] stopBgm()');
    if (_player == null || !_player!.playing) return;
    try {
      await _fadeOutAndStop(durationMs: 600);
    } catch (e) {
      debugPrint('[AudioService] stopBgm ERROR: $e');
    }
  }

  // ── Toggle dari Settings ──────────────────────────────────────────────────
  Future<void> setMusicEnabled(bool enabled) async {
    debugPrint('[AudioService] setMusicEnabled($enabled)');
    isMusicEnabledRx.value = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyMusic, enabled);

    if (_player == null) return;

    if (enabled) {
      await _fadeIn();
    } else {
      await _fadeOutAndStop();
    }
  }

  // ── Resume setelah keluar quiz ────────────────────────────────────────────
  Future<void> resumeIfEnabled() async {
    debugPrint('[AudioService] resumeIfEnabled()');
    if (!isMusicEnabledRx.value || _player == null || _player!.playing) return;
    _cancelFade();
    await _fadeIn();
  }

  // ── Fade out saat masuk quiz ──────────────────────────────────────────────
  Future<void> fadeOutAndPause({int durationMs = 800}) async {
    debugPrint('[AudioService] fadeOutAndPause()');
    if (_player == null || !_player!.playing) return;
    await _fadeOutAndStop(durationMs: durationMs);
  }

  Future<void> dispose() async {
    _cancelFade();
    await _player?.dispose();
    _player = null;
    _isInitialized = false;
  }

  // ── PRIVATE ───────────────────────────────────────────────────────────────

  Future<void> _fadeOutAndStop({int durationMs = 800}) async {
    _cancelFade();
    if (_player == null) return;

    _isStopping = true;

    const steps = 20;
    final stepDuration = Duration(milliseconds: durationMs ~/ steps);
    final startVolume = _player!.volume;
    final volumeStep = startVolume / steps;

    final completer = Completer<void>();
    int step = 0;

    _fadeTimer = Timer.periodic(stepDuration, (timer) {
      step++;
      final newVolume = (_player!.volume - volumeStep).clamp(0.0, 1.0);
      _player?.setVolume(newVolume);

      if (step >= steps || newVolume <= 0.0) {
        timer.cancel();
        _fadeTimer = null;
        _player?.setVolume(1.0);
        _player?.stop().then((_) {
          // FIX 2: reset flag setelah stop() selesai secara async
          _isStopping = false;
        });
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  Future<void> _fadeIn({int durationMs = 800}) async {
    _cancelFade();
    if (_player == null) return;

    // FIX 2: Jika stop masih berproses, tunggu sebentar sebelum play
    // agar AudioPlayer selesai transisi state dari playing→idle.
    if (_isStopping) {
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // seek ke awal karena stop() mereset posisi player
    await _player!.seek(Duration.zero);
    await _player!.setVolume(0.0);
    unawaited(
      _player!.play().catchError((e) {
        debugPrint('[AudioService] play ERROR: $e');
      }),
    );

    const steps = 20;
    final stepDuration = Duration(milliseconds: durationMs ~/ steps);
    const volumeStep = 1.0 / steps;
    double currentVolume = 0.0;

    _fadeTimer = Timer.periodic(stepDuration, (timer) {
      currentVolume = (currentVolume + volumeStep).clamp(0.0, 1.0);
      _player?.setVolume(currentVolume);

      if (currentVolume >= 1.0) {
        timer.cancel();
        _fadeTimer = null;
      }
    });
  }

  void _cancelFade() {
    _fadeTimer?.cancel();
    _fadeTimer = null;
  }
}
