import 'package:cloud_firestore/cloud_firestore.dart';

class RouteEvent {
  final String id;
  final String title;
  final DateTime date;
  final String location;

  RouteEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
  });

  // =========================
  // COPY WITH (ДЛЯ РЕДАГУВАННЯ)
  // =========================
  RouteEvent copyWith({
    String? title,
    DateTime? date,
    String? location,
  }) {
    return RouteEvent(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
    );
  }

  // =========================
  // FIRESTORE
  // =========================
  Map<String, dynamic> toFirestore() => {
    'title': title,
    'date': Timestamp.fromDate(date),
    'location': location,
  };

  factory RouteEvent.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RouteEvent(
      id: doc.id,
      title: d['title'] ?? '',
      date: (d['date'] as Timestamp).toDate(),
      location: d['location'] ?? '',
    );
  }
}
