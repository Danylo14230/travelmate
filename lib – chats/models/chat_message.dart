import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.createdAt,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: d['text'],
      senderId: d['senderId'],
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'text': text,
    'senderId': senderId,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
