import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> createChatForTrip({
    required String tripId,
    required String tripTitle,
  }) async {
    final ref = _db.collection('chats').doc(tripId);

    final snap = await ref.get();
    if (snap.exists) return;

    await ref.set({
      'tripId': tripId,
      'title': tripTitle,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageAt': null,
    });
  }
}
