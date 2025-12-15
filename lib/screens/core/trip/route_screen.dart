import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/route_event.dart';
import '../../../models/trip.dart';
import '../../../providers/route_provider.dart';
import '../../../providers/trip_provider.dart';
import '../../../widgets/date_picker_field.dart';

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

    tripId = ModalRoute.of(context)!.settings.arguments as String;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteProvider>().loadForTrip(tripId);
    });

    _loaded = true;
  }

  Trip _trip() => context.read<TripProvider>().getById(tripId)!;

  void _showRouteDialog({RouteEvent? event}) {
    final isEdit = event != null;

    final titleCtl = TextEditingController(text: event?.title ?? '');
    final locCtl = TextEditingController(text: event?.location ?? '');
    DateTime? date = event?.date;

    final trip = _trip();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isEdit ? 'Редагувати подію маршруту' : 'Додати подію маршруту'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtl,
                decoration: const InputDecoration(labelText: 'Назва'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locCtl,
                decoration: const InputDecoration(labelText: 'Локація'),
              ),
              const SizedBox(height: 12),
              DatePickerField(
                date: date,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: date ?? trip.startDate,
                    firstDate: trip.startDate,
                    lastDate: trip.endDate,
                  );
                  if (picked != null) {
                    setState(() => date = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtl.text.trim().isEmpty ||
                    locCtl.text.trim().isEmpty ||
                    date == null) {
                  return;
                }

                final trip = _trip();
                if (date!.isBefore(trip.startDate) || date!.isAfter(trip.endDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Дата події поза межами подорожі')),
                  );
                  return;
                }

                final provider = context.read<RouteProvider>();

                if (isEdit) {
                  await provider.updateEvent(
                    tripId,
                    event!.copyWith(
                      title: titleCtl.text.trim(),
                      location: locCtl.text.trim(),
                      date: date!,
                    ),
                  );
                } else {
                  await provider.addEvent(
                    tripId,
                    RouteEvent(
                      id: '',
                      title: titleCtl.text.trim(),
                      location: locCtl.text.trim(),
                      date: date!,
                    ),
                  );
                }

                Navigator.pop(ctx);
              },
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteProvider>();
    final events = provider.events;

    return Scaffold(
      appBar: AppBar(title: const Text('Маршрут')),
      body: events.isEmpty
          ? const Center(child: Text('Маршрут не задано'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final e = events[i];
          return Card(
            child: ListTile(
              title: Text(e.title),
              subtitle: Text(
                '${e.location} • '
                    '${e.date.day.toString().padLeft(2, '0')}.'
                    '${e.date.month.toString().padLeft(2, '0')}.'
                    '${e.date.year}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showRouteDialog(event: e),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => provider.deleteEvent(tripId, e.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRouteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
