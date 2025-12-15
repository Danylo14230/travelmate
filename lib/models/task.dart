import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final DateTime dueDate;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.completed,
  });

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'dueDate': Timestamp.fromDate(dueDate),
    'completed': completed,
  };

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: d['title'] ?? '',
      dueDate: (d['dueDate'] as Timestamp).toDate(),
      completed: d['completed'] ?? false,
    );
  }

  Task copyWith({
    String? title,
    DateTime? dueDate,
    bool? completed,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
    );
  }
}
