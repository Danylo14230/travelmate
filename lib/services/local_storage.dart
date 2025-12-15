
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // ← ОСЬ ЦЕ
import 'debug_storage.dart';


class LocalStorage {
  static Future<void> saveJson(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    await DebugStorage.logSet(key, value);
    await prefs.setString(key, jsonEncode(value));
  }

  static Future<dynamic> readJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    await DebugStorage.logGet(key, raw);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('❌ REMOVE [$key]');
    await prefs.remove(key);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('🔥 CLEAR ALL PREFS');
    await prefs.clear();
  }
}
