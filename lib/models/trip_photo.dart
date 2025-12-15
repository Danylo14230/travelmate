// lib/models/trip_photo.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TripPhoto {
  final String id;
  final String url;
  final String ownerId;
  final DateTime createdAt;

  TripPhoto({
    required this.id,
    required this.url,
    required this.ownerId,
    required this.createdAt,
  });

  factory TripPhoto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TripPhoto(
      id: doc.id,
      url: data['url'],
      ownerId: data['ownerId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
