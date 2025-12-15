import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryImage {
  final String id;
  final String tripId;
  final String url;
  final DateTime createdAt;

  GalleryImage({
    required this.id,
    required this.tripId,
    required this.url,
    required this.createdAt,
  });

  factory GalleryImage.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;

    final ts = data['createdAt'];

    return GalleryImage(
      id: doc.id,
      tripId: data['tripId'] as String,
      url: data['url'] as String,
      createdAt: ts is Timestamp
          ? ts.toDate()
          : DateTime.now(), // ✅ НЕ КРАШИТЬСЯ
    );
  }
}
