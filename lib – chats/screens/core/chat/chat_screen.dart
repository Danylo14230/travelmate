import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/chat_provider.dart';
import '../../../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final String tripId;
  final TextEditingController _textCtl = TextEditingController();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    // 🔥 tripId = id подорожі = id чату
    tripId = ModalRoute.of(context)!.settings.arguments as String;

    // 🔥 підписуємось на чат цієї подорожі
    context.read<ChatProvider>().listenTripChat(tripId);

    _loaded = true;
  }

  @override
  void dispose() {
    _textCtl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textCtl.text.trim();
    if (text.isEmpty) return;

    await context.read<ChatProvider>().sendMessage(
      tripId: tripId,
      text: text,
      senderId: 'me', // TODO: FirebaseAuth uid
    );

    _textCtl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<ChatProvider>().messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Чат подорожі'),
      ),
      body: Column(
        children: [
          /// ===== MESSAGES =====
          Expanded(
            child: messages.isEmpty
                ? const Center(
              child: Text(
                'Немає повідомлень\nНапишіть перше 👋',
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final ChatMessage m = messages[i];
                final bool isMe = m.senderId == 'me';

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),

          /// ===== INPUT =====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtl,
                      decoration: const InputDecoration(
                        hintText: 'Повідомлення...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
