import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String tripId;
  final String tripTitle;
  final String lastMessage;
  final DateTime? updatedAt;

  Chat({
    required this.tripId,
    required this.tripTitle,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Chat(
      tripId: doc.id,
      tripTitle: d['tripTitle'],
      lastMessage: d['lastMessage'] ?? '',
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
