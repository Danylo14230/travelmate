import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

class ExpensesProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Map<String, List<Expense>> _expensesByTrip = {};
  final Map<String, StreamSubscription> _subs = {};

  final Set<String> _loadingTrips = {};

  bool isLoadingFor(String tripId) => _loadingTrips.contains(tripId);

  // ===== READ =====

  List<Expense> expensesForTrip(String tripId) {
    return _expensesByTrip[tripId] ?? [];
  }

  double totalForTrip(String tripId) {
    final list = _expensesByTrip[tripId];
    if (list == null) return 0;
    return list.fold(0.0, (s, e) => s + e.amount);
  }

  // ===== LISTEN =====

  void loadForTrip(String tripId) {
    if (_subs.containsKey(tripId)) return; // вже слухаємо

    _loadingTrips.add(tripId);
    notifyListeners();

    _subs[tripId] = _db
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _expensesByTrip[tripId] =
          snapshot.docs.map(Expense.fromFirestore).toList();

      _loadingTrips.remove(tripId);
      notifyListeners();
    });
  }

  // ===== CRUD =====

  Future<void> addExpense(String tripId, Expense e) async {
    await _db
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .add(e.toFirestore());
  }

  Future<void> deleteExpense(String tripId, String expenseId) async {
    await _db
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  // ===== CLEANUP =====

  @override
  void dispose() {
    for (final s in _subs.values) {
      s.cancel();
    }
    super.dispose();
  }
  Future<void> updateExpense(String tripId, Expense e) async {
    await _db
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .doc(e.id)
        .update(e.toFirestore());
  }

}
