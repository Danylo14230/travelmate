import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;
  final List<String> destinations;
  final double budget;
  final String currency;
  final int readiness;

  Trip({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.destinations,
    required this.budget,
    required this.currency,
    required this.readiness,
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      title: data['title'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      duration: data['duration'],
      destinations: List<String>.from(data['destinations']),
      budget: (data['budget'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      readiness: data['readiness'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'duration': duration,
      'destinations': destinations,
      'budget': budget,
      'currency': currency,
      'readiness': readiness,
    };
  }
}
