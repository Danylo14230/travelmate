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
