import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import 'dart:async';

class ExpensesProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  StreamSubscription? _sub;

  void loadForTrip(String tripId) {
    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _expenses =
          snapshot.docs.map((d) => Expense.fromFirestore(d)).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addExpense(String tripId, Expense e) async {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .add(e.toFirestore());
  }

  Future<void> deleteExpense(String tripId, String expenseId) async {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

}
