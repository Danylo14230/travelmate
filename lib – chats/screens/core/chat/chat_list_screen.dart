import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../repositories/chat_repository.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  static const routeName = '/chats';
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripsStream = FirebaseFirestore.instance
        .collection('trips')
        .orderBy('startDate', descending: false)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Чати')),
      body: StreamBuilder<QuerySnapshot>(
        stream: tripsStream,
        builder: (ctx, snap) {
          if (snap.hasError) {
            return Center(child: Text('Помилка: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Немає подорожей — немає чатів'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final tripId = docs[i].id;
              final title = (d['title'] ?? 'Trip') as String;

              return _TripChatTile(
                tripId: tripId,
                title: title,
                onOpen: () async {
                  // 🔥 гарантуємо існування чату
                  await ChatRepository().createChatForTrip(
                    tripId: tripId,
                    tripTitle: title,
                  );

                  if (context.mounted) {
                    Navigator.of(context).pushNamed(
                      ChatScreen.routeName,
                      arguments: tripId, // chatId = tripId
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TripChatTile extends StatelessWidget {
  final String tripId;
  final String title;
  final Future<void> Function() onOpen;

  const _TripChatTile({
    required this.tripId,
    required this.title,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final chatDocStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(tripId)
        .snapshots();

    return InkWell(
      onTap: () async {
        try {
          await onOpen();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не вдалося відкрити чат: $e')),
          );
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const CircleAvatar(child: Icon(Icons.chat_bubble_outline)),
              const SizedBox(width: 12),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: chatDocStream,
                  builder: (_, snap) {
                    String subtitle = 'Натисни, щоб відкрити чат';
                    if (snap.hasData && snap.data!.exists) {
                      final m = snap.data!.data() as Map<String, dynamic>;
                      final last = (m['lastMessage'] ?? '') as String;
                      subtitle = last.isEmpty ? 'Порожній чат' : last;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    );
                  },
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
