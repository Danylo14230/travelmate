import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryImage {
  final String id;
  final String tripId;
  final String url;
  final Timestamp createdAt;

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
    return GalleryImage(
      id: doc.id,
      tripId: data['tripId'],
      url: data['url'],
      createdAt: data['createdAt'],
    );
  }
}
