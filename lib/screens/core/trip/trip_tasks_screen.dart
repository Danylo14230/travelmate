import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/trip_provider.dart';
import '../../../providers/tasks_provider.dart';
import '../../../models/task.dart';
import '../../../theme.dart';
import '../../../widgets/date_picker_field.dart';

class TripTasksScreen extends StatefulWidget {
  static const routeName = '/tasks';
  const TripTasksScreen({super.key});

  @override
  State<TripTasksScreen> createState() => _TripTasksScreenState();
}

class _TripTasksScreenState extends State<TripTasksScreen> {
  bool _loaded = false;
  late final String tripId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    tripId = ModalRoute.of(context)!.settings.arguments as String;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksProvider>().listenForTrip(tripId);
    });

    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TasksProvider>().tasksForTrip(tripId);

    return Scaffold(
      appBar: AppBar(title: const Text('Завдання')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context, tripId),
        child: const Icon(Icons.add),
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text(
          'Немає завдань',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final task = tasks[i];
          return _taskTile(
            context,
            tripId: tripId,
            task: task,
          );
        },
      ),
    );
  }

  void _showTaskDialog(BuildContext context, String tripId, {Task? task}) {
    final titleCtl = TextEditingController(text: task?.title ?? '');
    DateTime dueDate = task?.dueDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text(task == null ? 'Нове завдання' : 'Редагувати завдання'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtl,
                  decoration: const InputDecoration(
                    labelText: 'Назва завдання',
                  ),
                ),
                const SizedBox(height: 12),
                DatePickerField(
                  date: dueDate,
                  onTap: () async {
                    final trip = context.read<TripProvider>().getById(tripId)!;

                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate.isBefore(trip.startDate) ? dueDate : trip.startDate,
                      firstDate: DateTime.now(),
                      lastDate: trip.startDate,
                    );
                    if (picked != null) {
                      setState(() => dueDate = picked);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Скасувати'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleCtl.text.trim().isEmpty) return;

                  if (task == null) {
                    await context.read<TasksProvider>().addTask(
                      tripId,
                      titleCtl.text.trim(),
                      dueDate,
                    );
                  } else {
                    await context.read<TasksProvider>().updateTask(
                      tripId,
                      task.copyWith(
                        title: titleCtl.text.trim(),
                        dueDate: dueDate,
                      ),
                    );
                  }

                  Navigator.of(ctx).pop();
                },
                child: const Text('Зберегти'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _taskTile(
      BuildContext context, {
        required String tripId,
        required Task task,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) {
            context.read<TasksProvider>().toggleComplete(tripId, task);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? AppTheme.textMuted : AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          'До ${task.dueDate.day}.${task.dueDate.month}.${task.dueDate.year}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showTaskDialog(context, tripId, task: task),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                context.read<TasksProvider>().removeTask(tripId, task.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
