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

  // UI / calculated
  final double spent;
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
    this.spent = 0,
    this.readiness = 0,
  });

  // ================= FIRESTORE =================

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final start = (data['startDate'] as Timestamp).toDate();
    final end = (data['endDate'] as Timestamp).toDate();

    return Trip(
      id: doc.id,
      title: data['title'],
      startDate: start,
      endDate: end,
      duration: data['duration'] ??
          end.difference(start).inDays + 1,
      destinations:
      List<String>.from(data['destinations'] ?? []),
      budget: (data['budget'] as num).toDouble(),
      currency: data['currency'],
      spent: (data['spent'] ?? 0).toDouble(),
      readiness: data['readiness'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'duration': duration,
      'destinations': destinations,
      'budget': budget,
      'currency': currency,
      'spent': spent,
      'readiness': readiness,
    };
  }

  // ================= HELPERS =================

  Trip copyWith({
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? duration,
    List<String>? destinations,
    double? budget,
    String? currency,
    double? spent,
    int? readiness,
  }) {
    return Trip(
      id: id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      destinations: destinations ?? this.destinations,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      spent: spent ?? this.spent,
      readiness: readiness ?? this.readiness,
    );
  }
}
