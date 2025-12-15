import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/route_event.dart' as model;
import '../../../providers/route_provider.dart';


class RouteScreen extends StatefulWidget {
  static const routeName = '/route';
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  late final String tripId;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final arg = ModalRoute.of(context)?.settings.arguments;
    debugPrint('ROUTE SCREEN ARG: $arg');

    tripId = ModalRoute.of(context)!.settings.arguments as String;
    context.read<RouteProvider>().loadForTrip(tripId);
    _loaded = true;
  }

  Future<void> _addDialog() async {
    final titleCtl = TextEditingController();
    final locCtl = TextEditingController();
    DateTime? date;

    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Додати подію маршруту'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtl,
              decoration: const InputDecoration(labelText: 'Назва'),
            ),
            TextField(
              controller: locCtl,
              decoration: const InputDecoration(labelText: 'Локація'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) date = picked;
              },
              child: const Text('Обрати дату'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Скасувати')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtl.text.trim().isEmpty ||
                  locCtl.text.trim().isEmpty ||
                  date == null) {
                return;
              }

              final event = model.RouteEvent(
                id: '',
                title: titleCtl.text.trim(),
                date: date!,
                location: locCtl.text.trim(),
              );


              await context
                  .read<RouteProvider>()
                  .addEvent(tripId, event);

              Navigator.of(ctx).pop(true);
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );

    if (res == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Подію додано')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteProvider>();
    final events = provider.events;

    return Scaffold(
      appBar: AppBar(title: const Text('Маршрут')),
      body: events.isEmpty
          ? const Center(child: Text('Маршрут порожній'))
          : ListView(
        children: events
            .map((e) => Card(
          child: ListTile(
            title: Text(e.title),
            subtitle: Text(
                '${e.location} • ${e.date.toIso8601String().split('T').first}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => provider.deleteEvent(tripId, e.id),
            ),
          ),
        ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
