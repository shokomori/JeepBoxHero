import 'package:flame_audio/flame_audio.dart';

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

  /// Call once on app start (before playing audio). This preloads common audio files.
  Future<void> initialize({List<String>? additionalAssets}) async {
    if (_initialized) return;

    final defaultAssets = <String>[
      'bgm_shop_ambient.mp3',
      'sfx_bell_customer.mp3',
      'sfx_receipt_tear.mp3',
      'sfx_vinyl_place.mp3',
      'sfx_page_turn.mp3',
      'sfx_cash_register.mp3',
    ];

    final toLoad = <String>[]..addAll(defaultAssets);
    if (additionalAssets != null) toLoad.addAll(additionalAssets);

    // Load filenames (FlameAudio's cache resolves assets/audio/ by default when
    // the assets are declared under assets/audio/ in pubspec.yaml).
    await FlameAudio.audioCache.loadAll(toLoad);

    _initialized = true;
  }

  // BGM controls
  Future<void> playBgm(String filename,
      {double? volume, bool loop = true, bool restart = false}) async {
    if (!_initialized) await initialize();

    // filenames should be relative to assets/audio/ when using FlameAudio
    final name = filename.startsWith('audio/') ? filename : 'audio/$filename';
    _currentBgm = filename;
    _bgmVolume = volume ?? _bgmVolume;

    if (_muted) return;

    if (restart) {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(name, volume: _bgmVolume);
      _bgmPlaying = true;
      return;
    }

    if (!_bgmPlaying) {
      await FlameAudio.bgm.play(name, volume: _bgmVolume);
      _bgmPlaying = true;
    }
  }

  Future<void> stopBgm() async {
    await FlameAudio.bgm.stop();
    _bgmPlaying = false;
    _currentBgm = null;
  }

  Future<void> pauseBgm() async {
    await FlameAudio.bgm.pause();
    _bgmPlaying = false;
  }

  Future<void> resumeBgm() async {
    if (_muted) return;
    await FlameAudio.bgm.resume();
    _bgmPlaying = true;
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
    final path = filename.startsWith('audio/') ? filename : 'audio/$filename';
    await FlameAudio.play(path, volume: (volume ?? _sfxVolume));
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
