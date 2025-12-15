import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/task.dart';
import '../../../providers/tasks_provider.dart';
import '../../../providers/trip_provider.dart';

class TripTasksScreen extends StatefulWidget {
  static const routeName = '/trip-tasks';
  const TripTasksScreen({super.key});

  @override
  State<TripTasksScreen> createState() => _TripTasksScreenState();
}

class _TripTasksScreenState extends State<TripTasksScreen> {
  late final String tripId;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    tripId = ModalRoute.of(context)!.settings.arguments as String;
    context.read<TasksProvider>().listenForTrip(tripId);
    _loaded = true;
  }

  DateTime get _tripStart =>
      context.read<TripProvider>().getById(tripId)!.startDate;

  Future<void> _showAddEditDialog({Task? existing}) async {
    final titleCtl = TextEditingController(text: existing?.title ?? '');
    DateTime? due = existing?.dueDate;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Додати завдання' : 'Редагувати завдання'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtl,
              decoration: const InputDecoration(labelText: 'Назва'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: due ?? _tripStart,
                  firstDate: _tripStart,
                  lastDate: DateTime(2100),
                );
                if (picked != null) due = picked;
              },
              child: const Text('Обрати дату'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtl.text.trim().isEmpty || due == null) return;

              final provider = context.read<TasksProvider>();

              if (existing == null) {
                await provider.addTask(
                  tripId,
                  titleCtl.text.trim(),
                  due!,
                );

              } else {
                await provider.updateTask(
                  tripId,
                  existing.copyWith(
                    title: titleCtl.text.trim(),
                    dueDate: due!,
                  ),
                );
              }

              Navigator.of(ctx).pop(true);
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );

    if (ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Зміни збережено')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TasksProvider>();
    final tasks = provider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Завдання'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('Немає завдань'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (_, i) {
          final t = tasks[i];
          return ListTile(
            leading: Checkbox(
              value: t.completed,
              onChanged: (_) =>
                  provider.toggleComplete(tripId, t),
            ),
            title: Text(
              t.title,
              style: t.completed
                  ? const TextStyle(
                  decoration: TextDecoration.lineThrough)
                  : null,
            ),
            subtitle: Text(
                'До ${t.dueDate.toIso8601String().split('T').first}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  _showAddEditDialog(existing: t),
            ),
            onLongPress: () =>
                provider.removeTask(tripId, t.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
