// lib/shared/services/audio_service.dart
//
// FIX UTAMA:
// 1. _fadeOutAndStop → pakai stop() bukan pause()
//    pause() membiarkan AudioTrack tetap terbuka → Android terus-terusan
//    melaporkan "isLongTimeZoreData" karena menerima silence tanpa batas.
//    stop() menutup AudioTrack sepenuhnya → warning hilang.
//
// 2. _fadeIn → seek(Duration.zero) dulu sebelum play()
//    Karena stop() mereset posisi, seek memastikan playback mulai dari awal.
//
// 3. Gapless loop → LoopingAudioSource
//    MP3 punya encoder-delay yang menciptakan gap kecil saat loop.
//    LoopingAudioSource mengelola loop secara internal sehingga
//    c2.android.mp3.decoder tidak idle di titik loop.
//
// REKOMENDASI TAMBAHAN (di luar kode):
//    Ganti bgm_main.mp3 → bgm_main.ogg (Vorbis).
//    OGG tidak punya encoder-delay → loop benar-benar seamless tanpa gap.

import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
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
  bool _isMusicEnabled = true;

  Timer? _fadeTimer;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isPlaying => _player?.playing ?? false;

  // ── Init tanpa play ───────────────────────────────────────────────────────
  Future<void> initWithoutPlay() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicEnabled = prefs.getBool(_prefKeyMusic) ?? true;

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

      // FIX: LoopingAudioSource mengelola loop secara internal di just_audio,
      // sehingga decoder tidak idle di titik loop → tidak ada gap silence.
      // count: 100 setara "infinite" untuk BGM game.
      final loopingSource = LoopingAudioSource(
        count: 100,
        child: AudioSource.asset(_bgmAsset),
      );
      await _player!.setAudioSource(loopingSource);
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

    if (!_isMusicEnabled) return;

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
    _isMusicEnabled = enabled;

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
    if (!_isMusicEnabled || _player == null || _player!.playing) return;
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

  // FIX: Menggunakan stop() bukan pause().
  //
  // pause() → AudioTrack tetap terbuka tapi menerima silence → Android log:
  //   "isLongTimeZoreData zoer date time X Seconds" selama berjam-jam.
  //
  // stop() → AudioTrack ditutup sepenuhnya → warning hilang.
  //
  // Konsekuensi: saat play() lagi, just_audio perlu seek ke posisi awal.
  // Ini ditangani di _fadeIn() dengan seek(Duration.zero).
  Future<void> _fadeOutAndStop({int durationMs = 800}) async {
    _cancelFade();
    if (_player == null) return;

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
        // Reset volume ke 1.0 dulu agar saat _fadeIn tidak perlu set ulang.
        _player?.setVolume(1.0);
        // FIX: stop() menutup AudioTrack → tidak ada lagi "isLongTimeZoreData".
        _player?.stop();
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  Future<void> _fadeIn({int durationMs = 800}) async {
    _cancelFade();
    if (_player == null) return;

    // FIX: seek ke awal karena stop() mereset posisi player internal.
    // Tanpa ini, playback bisa mulai dari posisi terakhir yang tidak terduga.
    await _player!.seek(Duration.zero);
    await _player!.setVolume(0.0);
    await _player!.play();

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
