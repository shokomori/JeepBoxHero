import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;
  bool _bgmPlaying = false;
  double _bgmVolume = 0.3;
  double _sfxVolume = 0.7;
  bool _muted = false;
  String? _currentBgm;
  // Player used for transient per-encounter music/themes
  final AudioPlayer _musicPlayer = AudioPlayer();
  // Player used for persistent shop ambient that should continue across screens
  final AudioPlayer _ambientPlayer = AudioPlayer();
  double _ambientVolume = 0.25;

  /// Call once on app start (before playing audio). This preloads common audio files.
  Future<void> initialize({List<String>? additionalAssets}) async {
    if (_initialized) return;

    final defaultAssets = <String>[
      'bgm_shop_ambient.mp3',
      'menu_music.mp3',
      'sfx_bell_customer.mp3',
      'sfx_receipt_tear.mp3',
      'sfx_page_turn.mp3',
      'sfx_cash_register.mp3',
    ];

    final toLoad = <String>[]..addAll(defaultAssets);
    if (additionalAssets != null) toLoad.addAll(additionalAssets);

    // Load filenames (FlameAudio's cache resolves assets/audio/ by default
    // when the assets are declared under assets/audio/ in pubspec.yaml).
    // Load assets individually so we can log any failures per file.
    try {
      for (final asset in toLoad) {
        try {
          await FlameAudio.audioCache.load(asset);
          debugPrint('AudioManager: loaded asset $asset');
        } catch (e) {
          debugPrint('AudioManager: failed to load asset $asset — $e');
        }
      }
      _initialized = true;
      debugPrint(
          'AudioManager: initialization complete (${toLoad.length} assets processed)');
    } catch (e) {
      debugPrint('AudioManager: initialize failed: $e');
      rethrow;
    }
  }

  // BGM controls
  Future<void> playBgm(String filename,
      {double? volume, bool loop = true, bool restart = false}) async {
    if (!_initialized) await initialize();

    // Use the same key that was used during initialization. If callers
    // passed 'audio/...' strip the prefix so we don't produce
    // 'assets/audio/audio/...' which will fail on web.
    final name =
        filename.startsWith('audio/') ? filename.substring(6) : filename;
    _currentBgm = filename;
    _bgmVolume = volume ?? _bgmVolume;

    if (_muted) return;

    debugPrint(
        'AudioManager: playBgm request -> $name (volume: $_bgmVolume, loop: $loop, restart: $restart)');

    // Use _musicPlayer for per-encounter music so ambient can keep playing.
    try {
      if (restart) {
        await _musicPlayer.stop();
      }

      await _musicPlayer
          .setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);

      // Play from assets/audio/<name>
      final assetPath = 'audio/$name';
      final encoded = Uri.encodeFull(assetPath);
      await _musicPlayer.play(AssetSource(encoded), volume: _bgmVolume);
      _bgmPlaying = true;
    } catch (e) {
      debugPrint('AudioManager: playBgm failed for $name -> $e');
    }
  }

  Future<void> stopBgm() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
    _bgmPlaying = false;
    _currentBgm = null;
  }

  Future<void> pauseBgm() async {
    try {
      await _musicPlayer.pause();
    } catch (_) {}
    _bgmPlaying = false;
  }

  Future<void> resumeBgm() async {
    if (_muted) return;
    try {
      await _musicPlayer.resume();
    } catch (_) {}
    _bgmPlaying = true;
  }

  // Ambient controls (persistent shop background)
  Future<void> playAmbient(String filename,
      {double? volume, bool loop = true}) async {
    if (!_initialized) await initialize();
    if (_muted) return;
    final name =
        filename.startsWith('audio/') ? filename.substring(6) : filename;
    _ambientVolume = volume ?? _ambientVolume;
    try {
      await _ambientPlayer
          .setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
      final assetPath = 'audio/$name';
      final encoded = Uri.encodeFull(assetPath);
      await _ambientPlayer.play(AssetSource(encoded), volume: _ambientVolume);
      debugPrint(
          'AudioManager: playAmbient -> $name (volume: $_ambientVolume, loop: $loop)');
    } catch (e) {
      debugPrint('AudioManager: playAmbient failed for $name -> $e');
    }
  }

  Future<void> stopAmbient() async {
    try {
      await _ambientPlayer.stop();
    } catch (_) {}
    // ambient stopped
  }

  Future<void> pauseAmbient() async {
    try {
      await _ambientPlayer.pause();
    } catch (_) {}
    // ambient paused
  }

  Future<void> resumeAmbient() async {
    if (_muted) return;
    try {
      await _ambientPlayer.resume();
    } catch (_) {}
    // ambient resumed
  }

  Future<void> setBgmVolume(double volume) async {
    _bgmVolume = volume.clamp(0.0, 1.0);
    if (_muted) return;

    // FlameAudio's BGM does not provide a direct setVolume across players in
    // all versions, so restart the current bgm with the new volume if playing.
    if (_bgmPlaying && _currentBgm != null) {
      await stopBgm();
      await playBgm(_currentBgm!, volume: _bgmVolume, restart: true);
    }
  }

  // SFX playback
  Future<void> playSfx(String filename, {double? volume}) async {
    if (!_initialized) await initialize();

    if (_muted) return;
    final path =
        filename.startsWith('audio/') ? filename.substring(6) : filename;
    debugPrint(
        'AudioManager: playSfx request -> $path (volume: ${volume ?? _sfxVolume})');
    try {
      await FlameAudio.play(path, volume: (volume ?? _sfxVolume));
    } catch (e) {
      debugPrint('AudioManager: playSfx failed for $path -> $e');
    }
  }

  /// Convenience method for quick SFX testing
  Future<void> playTestSfx() async {
    await playSfx('sfx_bell_customer.mp3');
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  // Mute/unmute
  Future<void> mute() async {
    _muted = true;
    // Pause BGM when muting
    if (_bgmPlaying) await pauseBgm();
  }

  Future<void> unmute() async {
    _muted = false;
    // Resume BGM when unmuting
    if (!_bgmPlaying && _currentBgm != null) {
      await playBgm(_currentBgm!, volume: _bgmVolume, restart: true);
    } else if (_bgmPlaying) {
      await resumeBgm();
    }
  }

  bool get isMuted => _muted;

  String? get currentBgm => _currentBgm;
}
