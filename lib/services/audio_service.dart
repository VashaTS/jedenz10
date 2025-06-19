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

  Future<void> playStart()        => playClip('start.mp3');
  Future<void> playEnd()          => playClip('end.mp3');
  Future<void> playCorrect()      => playClip('correct.mp3');
  Future<void> playWrong()        => playClip('wrong.mp3');     // ❗ now returns Future
  Future<void> playEliminated()   => playClip('eliminated.mp3'); // ← new short jingle
  void dispose() => _player.dispose();
  void stop() => _player.stop();
}