// lib/services/player_store.dart  – very small helper
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

class PlayerStore {
  static const _key = 'players';

  /// Save current list
  static Future<void> save(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    final data = players
        .map((p) => {
      'name'  : p.name,
      'avatar': p.icon is FileImage
          ? (p.icon as FileImage).file.path
          : null,                 // asset/default icon → null
    })
        .toList();
    await prefs.setString(_key, jsonEncode(data));
  }

  /// Load list (returns empty if nothing stored)
  static Future<List<Player>> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded.map<Player>((rwa) {
      final e = rwa as Map<String,dynamic>;
      final String? path = e['avatar'] as String?;
      final ImageProvider<Object> avatar = path == null
          ? const AssetImage('assets/default_icon_new.png') as ImageProvider<Object>
          : FileImage(File(path)) as ImageProvider<Object>;
      return Player(
        e['name'] as String,
        avatar,
        0,                      // lives will be injected later
      );
    }).toList();
  }
}
