// ===============================
//  file: lib/services/audio_service.dart
// ===============================
import 'package:audioplayers/audioplayers.dart';

import '../models/game_settings.dart';

class AudioService {
  final GameSettings _settings;
  final AudioPlayer _player = AudioPlayer();
  AudioService(this._settings);

  Future<void> playClip(String asset) async {
    if (!_settings.soundEnabled) return;
    await _player.stop();
    await _player.play(AssetSource(asset));
  }

  void playStart()   { if (!_settings.soundEnabled) return;
  _player.play(AssetSource('start.mp3')); }
  void playCorrect() { if (!_settings.soundEnabled) return;
  _player.play(AssetSource('correct.mp3')); }
  void playWrong()   { if (!_settings.soundEnabled) return;
  _player.play(AssetSource('wrong.mp3')); }
  void playEnd()     { if (!_settings.soundEnabled) return;
  _player.play(AssetSource('end.mp3')); }
  void dispose() => _player.dispose();
  void stop() => _player.stop();
}