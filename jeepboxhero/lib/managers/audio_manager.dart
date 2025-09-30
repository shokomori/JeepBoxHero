import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await FlameAudio.audioCache.loadAll([
      'bgm_shop_ambient.mp3',
      'sfx_bell_customer.mp3',
      'sfx_receipt_tear.mp3',
      'sfx_vinyl_place.mp3',
      'sfx_page_turn.mp3',
      'sfx_cash_register.mp3',
    ]);

    _initialized = true;
  }

  Future<void> playBGM() async {
    await FlameAudio.bgm.play('bgm_shop_ambient.mp3', volume: 0.3);
  }

  Future<void> playCustomerBell() async {
    await FlameAudio.play('sfx_bell_customer.mp3', volume: 0.5);
  }

  Future<void> playReceiptTear() async {
    await FlameAudio.play('sfx_receipt_tear.mp3', volume: 0.6);
  }

  Future<void> playVinylPlace() async {
    await FlameAudio.play('sfx_vinyl_place.mp3', volume: 0.4);
  }

  Future<void> playPageTurn() async {
    await FlameAudio.play('sfx_page_turn.mp3', volume: 0.3);
  }

  Future<void> playCashRegister() async {
    await FlameAudio.play('sfx_cash_register.mp3', volume: 0.5);
  }

  void stopBGM() {
    FlameAudio.bgm.stop();
  }
}
