import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugStorage {
  static Future<void> dumpAll() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('================ PREFS DUMP ================');

    for (final key in prefs.getKeys()) {
      final value = prefs.get(key);
      debugPrint('KEY: $key');
      debugPrint('RAW: $value');

      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          debugPrint('JSON: $decoded');
        } catch (_) {
          debugPrint('NOT JSON STRING');
        }
      }
      debugPrint('-------------------------------------------');
    }

    debugPrint('============== END PREFS DUMP ==============');
  }

  static Future<void> logSet(String key, Object value) async {
    debugPrint('💾 SET [$key]');
    debugPrint(jsonEncode(value));
  }

  static Future<void> logGet(String key, dynamic value) async {
    debugPrint('📦 GET [$key]');
    debugPrint(value == null ? 'NULL' : value.toString());
  }
}
