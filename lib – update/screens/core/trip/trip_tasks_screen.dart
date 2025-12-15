import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/tasks_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TasksProvider>().tasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Завдання')),
      body: tasks.isEmpty
          ? const Center(child: Text('Немає завдань'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (_, i) => ListTile(
          leading: Checkbox(
            value: tasks[i].completed,
            onChanged: (_) => context
                .read<TasksProvider>()
                .toggleComplete(tripId, tasks[i]),
          ),
          title: Text(tasks[i].title),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
