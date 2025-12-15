import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class TasksProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  StreamSubscription? _sub;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  // 🔥 ПІДПИСУЄМОСЬ НА TASKS КОНКРЕТНОЇ ПОДОРОЖІ
  void listenForTrip(String tripId) {
    _sub?.cancel();

    _sub = _db
        .collection('trips')
        .doc(tripId)
        .collection('tasks')
        .orderBy('dueDate')
        .snapshots()
        .listen((snapshot) {
      _tasks = snapshot.docs
          .map((d) => Task.fromFirestore(d))
          .toList();

      notifyListeners();
    });
  }

  List<Task> tasksForTrip(String tripId) {
    // 🔥 вже відфільтровано стрімом
    return _tasks;
  }

  Future<void> addTask(
      String tripId,
      String title,
      DateTime dueDate,
      ) async {
    await _db
        .collection('trips')
        .doc(tripId)
        .collection('tasks')
        .add({
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'completed': false,
    });
  }

  Future<void> toggleComplete(String tripId, Task task) async {
    await _db
        .collection('trips')
        .doc(tripId)
        .collection('tasks')
        .doc(task.id)
        .update({
      'completed': !task.completed,
    });
  }

  Future<void> removeTask(String tripId, String taskId) async {
    await _db
        .collection('trips')
        .doc(tripId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
  Future<void> updateTask(String tripId, Task task) async {
    await _db
        .collection('trips')
        .doc(tripId)
        .collection('tasks')
        .doc(task.id)
        .update({
      'title': task.title,
      'dueDate': Timestamp.fromDate(task.dueDate),
      'completed': task.completed,
    });
  }

}
