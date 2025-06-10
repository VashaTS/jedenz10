import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/highscore_entry.dart';

class HighscoreService {
  static const _prefix = 'hiscore_';         // np. hiscore_3

  static Future<List<HighscoreEntry>> load(int lives) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_prefix$lives');
    if (jsonStr == null) return [];
    final list = (json.decode(jsonStr) as List)
        .map((e) => HighscoreEntry.fromJson(e))
        .toList();
    return list;
  }

  static Future<void> save(int lives, List<HighscoreEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(list.map((e) => e.toJson()).toList());
    await prefs.setString('$_prefix$lives', jsonStr);
  }

  /// próbuje dodać wynik i zwraca listę już obciętą do TOP-10
  static Future<List<HighscoreEntry>> add(
      int lives, HighscoreEntry entry) async {
    final list = await load(lives)..add(entry);
    list.sort((a, b) => b.score.compareTo(a.score)); // malejąco
    final top = list.take(10).toList();
    await save(lives, top);
    return top;
  }
}
