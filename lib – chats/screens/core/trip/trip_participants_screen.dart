import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/participants_provider.dart';

class TripParticipantsScreen extends StatelessWidget {
  static const routeName = '/trip-participants';
  const TripParticipantsScreen({super.key});

  Future<void> _showAddDialog(BuildContext context, String tripId) async {
    final nameCtl = TextEditingController();
    final emailCtl = TextEditingController();
    final roleCtl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Додати учасника'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Імʼя')),
            TextField(controller: emailCtl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: roleCtl, decoration: const InputDecoration(labelText: 'Роль')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Скасувати')),
          ElevatedButton(
              onPressed: () {
                if (nameCtl.text.trim().isEmpty) return;
                context.read<ParticipantsProvider>().add(
                  tripId,
                  nameCtl.text.trim(),
                  emailCtl.text.trim(),
                  roleCtl.text.trim(),
                );
                Navigator.pop(ctx, true);
              },
              child: const Text('Додати')),
        ],
      ),
    );

    if (ok == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Учасника додано')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    final provider = context.watch<ParticipantsProvider>();
    final participants = provider.participants(tripId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Учасники подорожі'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
              onPressed: () => _showAddDialog(context, tripId),
              icon: const Icon(Icons.person_add))
        ],
      ),
      body: participants.isEmpty
          ? const Center(child: Text('Немає учасників'))
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: participants.length,
        itemBuilder: (ctx, i) {
          final p = participants[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(p['name']!.substring(0, 1)),
              ),
              title: Text(p['name']!),
              subtitle: Text(
                '${p['role']}\n${p['email']}',
                style: const TextStyle(fontSize: 12),
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'remove') {
                    context.read<ParticipantsProvider>().remove(tripId, i);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'remove', child: Text('Видалити')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
