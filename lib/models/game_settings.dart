import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettings extends ChangeNotifier {
  bool soundEnabled;
  int defaultLives;
  bool useTimer;
  int timeSeconds;
  int recencyWindow;
  bool autoFail;

  GameSettings({
    this.soundEnabled = true,
    this.defaultLives = 3,
    this.useTimer     = true,
    this.timeSeconds  = 15,
    this.recencyWindow = 10,
    this.autoFail      = false,
  });

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    soundEnabled = prefs.getBool('sound') ?? true;
    defaultLives = prefs.getInt('defaultLives') ?? 3;
    useTimer      = prefs.getBool('useTimer')     ?? true;
    timeSeconds   = prefs.getInt('timeSeconds')   ?? 15;
    recencyWindow  = prefs.getInt('recencyWindow')    ?? 10;
    autoFail     = prefs.getBool('autoFail')      ?? false;
    notifyListeners();
  }

  Future<void> toggleSound() async {
    soundEnabled = !soundEnabled;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool('sound', soundEnabled);
  }

  Future<void> setDefaultLives(int v) async {
    defaultLives = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setInt('defaultLives', v);
  }

  Future<void> toggleTimer() async {
    useTimer = !useTimer;
    notifyListeners();
    (await SharedPreferences.getInstance())
        .setBool('useTimer', useTimer);
  }

  Future<void> setTimeSeconds(int v) async {
    timeSeconds = v;
    notifyListeners();
    (await SharedPreferences.getInstance())
        .setInt('timeSeconds', v);
  }
  Future<void> setRecencyWindow(int v) async {
    recencyWindow = v.clamp(10, 1000);
    notifyListeners();
    (await SharedPreferences.getInstance())
        .setInt('recencyWindow', recencyWindow);
  }
  Future<void> toggleAutoFail() async {
    autoFail = !autoFail;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool('autoFail', autoFail);
  }
}
