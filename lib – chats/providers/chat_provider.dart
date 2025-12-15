import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  StreamSubscription? _listSub;
  StreamSubscription? _chatSub;

  List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  // ===== CHAT LIST =====

  void listenChats() {
    _listSub?.cancel();

    _listSub = _db
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snap) {
      _chats = snap.docs.map((d) => Chat.fromFirestore(d)).toList();
      notifyListeners();
    });
  }

  // ===== SINGLE CHAT =====

  void listenTripChat(String tripId) {
    _chatSub?.cancel();

    _chatSub = _db
        .collection('chats')
        .doc(tripId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .listen((snap) {
      _messages =
          snap.docs.map((d) => ChatMessage.fromFirestore(d)).toList();
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String tripId,
    required String text,
    required String senderId,
  }) async {
    final chatRef = _db.collection('chats').doc(tripId);

    await chatRef.collection('messages').add({
      'text': text,
      'senderId': senderId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await chatRef.update({
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _listSub?.cancel();
    _chatSub?.cancel();
    super.dispose();
  }
}
