import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/trip.dart';
import '../../../providers/trip_provider.dart';
import '../../../widgets/section_card.dart';

import 'expenses_screen.dart';
import 'route_screen.dart';
import 'trip_tasks_screen.dart';
import '../gallery/trip_gallery_screen.dart';

class TripScreen extends StatelessWidget {
  static const routeName = '/trip';
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    final trip = context.watch<TripProvider>().getById(tripId);

    if (trip == null) {
      return const Scaffold(
        body: Center(child: Text('Подорож не знайдена')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(trip.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _hero(trip),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Завдання',
              icon: Icons.task_alt,
              onTap: () => Navigator.of(context).pushNamed(
                TripTasksScreen.routeName,
                arguments: trip.id,
              ),
            ),
            SectionCard(
              title: 'Бюджет',
              icon: Icons.account_balance_wallet,
              onTap: () => Navigator.of(context).pushNamed(
                ExpensesScreen.routeName,
                arguments: trip.id,
              ),
            ),
            SectionCard(
              title: 'Маршрут',
              icon: Icons.map,
              onTap: () => Navigator.of(context).pushNamed(
                RouteScreen.routeName,
                arguments: trip.id,
              ),
            ),

            SectionCard(
              title: 'Галерея',
              icon: Icons.photo_library,
              onTap: () => Navigator.of(context).pushNamed(
                TripGalleryScreen.routeName,
                arguments: trip.id,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(Trip trip) {
    final progress = (trip.readiness / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '${_fmt(trip.startDate)} — ${_fmt(trip.endDate)} • ${trip.duration} днів',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 6),
          Text('Готовність: ${trip.readiness}%'),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
