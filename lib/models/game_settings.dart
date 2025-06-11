import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettings extends ChangeNotifier {
  bool soundEnabled;
  int defaultLives;
  bool useTimer;
  int timeSeconds;
  int recencyWindow;
  bool autoFail;

  final SharedPreferences _prefs;

  GameSettings._(
    this._prefs,{
      required this.soundEnabled,
      required this.defaultLives,
      required this.useTimer,
      required this.timeSeconds,
      required this.recencyWindow,
      required this.autoFail,
  });

  static Future<GameSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return GameSettings._(
      p,
      soundEnabled   : p.getBool ('sound')         ?? true,
      defaultLives   : p.getInt  ('defaultLives')  ?? 3,
      useTimer       : p.getBool ('useTimer')      ?? true,
      timeSeconds    : p.getInt  ('timeSeconds')   ?? 15,
      recencyWindow  : p.getInt  ('recencyWindow') ?? 10,
      autoFail       : p.getBool ('autoFail')      ?? false,
    );
  }
  Future<void> toggleSound() async {
    soundEnabled = !soundEnabled;
    await _prefs.setBool('sound', soundEnabled);
    notifyListeners();
  }

  Future<void> setDefaultLives(int v) async {
    defaultLives = v.clamp(1, 99);
    await _prefs.setInt('defaultLives', defaultLives);
    notifyListeners();
  }

  Future<void> toggleTimer() async {
    useTimer = !useTimer;
    await _prefs.setBool('useTimer', useTimer);
    notifyListeners();
  }

  Future<void> setTimeSeconds(int v) async {
    timeSeconds = v.clamp(5, 120);
    await _prefs.setInt('timeSeconds', timeSeconds);
    notifyListeners();
  }

  Future<void> setRecencyWindow(int v) async {
    recencyWindow = v.clamp(10, 1000);
    await _prefs.setInt('recencyWindow', recencyWindow);
    notifyListeners();
  }

  Future<void> toggleAutoFail() async {
    autoFail = !autoFail;
    await _prefs.setBool('autoFail', autoFail);
    notifyListeners();
  }

}
