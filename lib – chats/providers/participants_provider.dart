import 'package:flutter/material.dart';

import '../services/local_storage.dart';
import 'load_state.dart';

class ParticipantsProvider with ChangeNotifier {
  static const String _key = 'participants_v1';

  // tripId -> list of participants
  final Map<String, List<Map<String, String>>> _data = {};

  LoadState state = LoadState.idle;
  String? error;

  ParticipantsProvider() {
    load();
  }

  Map<String, List<Map<String, String>>> _seed() => {
    '1': [
      {'id': 'p1', 'name': 'Олена Коваленко', 'role': 'Організатор', 'email': 'olena@example.com'},
      {'id': 'p2', 'name': 'Тарас Петренко', 'role': 'Учасник', 'email': 'taras@example.com'},
    ],
    '2': [
      {'id': 'p3', 'name': 'Іван Іванов', 'role': 'Організатор', 'email': 'ivan@example.com'},
    ],
  };

  Future<void> load({bool withError = false}) async {
    state = LoadState.loading;
    error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 150));

    if (withError) {
      state = LoadState.error;
      error = 'Failed to load participants';
      notifyListeners();
      return;
    }

    final data = await LocalStorage.readJson(_key);

    _data.clear();

    if (data == null) {
      // ✅ МІГРАЦІЯ: перший запуск → seed → local
      _data.addAll(_seed());
      await _save();
    } else {
      final map = Map<String, dynamic>.from(data as Map);
      for (final entry in map.entries) {
        _data[entry.key] = (entry.value as List)
            .map((x) => Map<String, String>.from(x as Map))
            .toList();
      }
    }

    state = LoadState.loaded;
    notifyListeners();
  }

  Future<void> _save() async {
    await LocalStorage.saveJson(_key, _data);
  }

  // ===== EXISTING API (UNTOUCHED) =====

  List<Map<String, String>> participants(String tripId) {
    return List<Map<String, String>>.from(_data[tripId] ?? []);
  }

  void add(String tripId, String name, String email, String role) {
    _data.putIfAbsent(tripId, () => []);
    _data[tripId]!.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'email': email,
      'role': role,
    });
    _save();
    notifyListeners();
  }

  void remove(String tripId, int index) {
    final list = _data[tripId];
    if (list == null || index < 0 || index >= list.length) return;

    list.removeAt(index);
    _save();
    notifyListeners();
  }
}
