import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/trip_provider.dart';
import '../../../models/trip.dart';

import '../trip/route_screen.dart';
import 'expenses_screen.dart';
import 'trip_tasks_screen.dart';
import 'trip_participants_screen.dart';

import '../../../widgets/section_card.dart';
import '../../../widgets/app_button.dart';

class TripScreen extends StatelessWidget {
  static const routeName = '/trip';
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;

    final tripsProvider = Provider.of<TripProvider>(context);
    final trip = tripsProvider.getById(tripId);

    if (trip == null) {
      return const Scaffold(
        body: Center(child: Text('Подорож не знайдена')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(trip.title),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
              onPressed: () => _showShare(context, trip),
              icon: const Icon(Icons.share)),
          IconButton(
              onPressed: () => _showExport(context, trip),
              icon: const Icon(Icons.download)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            //_statusCard(trip),
            const SizedBox(height: 12),

            SectionCard(
              title: 'Завдання перед виїздом',
              icon: Icons.task_alt,
              onTap: () {
                Navigator.of(context).pushNamed(
                  TripTasksScreen.routeName,
                  arguments: trip.id,
                );
              },
            ),

            SectionCard(
              title: 'Бюджет',
              icon: Icons.account_balance_wallet,
              onTap: () {
                Navigator.of(context).pushNamed(
                  ExpensesScreen.routeName,
                  arguments: trip.id,
                );
              },
            ),

            SectionCard(
              title: 'Маршрут по днях',
              icon: Icons.map,
              onTap: () {
                Navigator.of(context).pushNamed(
                  RouteScreen.routeName,
                  arguments: trip.id,
                );
              },
            ),

            SectionCard(
              title: 'Учасники',
              icon: Icons.people,
              onTap: () {
                Navigator.of(context).pushNamed(
                  TripParticipantsScreen.routeName,
                  arguments: trip.id,
                );
              },
            ),

            const SizedBox(height: 18),

            AppButton(
              label: 'Експорт',
              color: Colors.orange,
              onPressed: () => _showExport(context, trip),
            )
          ],
        ),
      ),
    );
  }

  // ------------------------
/*
  Widget _statusCard(Trip trip) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.white]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ДО ВИЇЗДУ',
                          style:
                          TextStyle(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 6),
                      Text(
                        '${_daysUntil(trip.startDate)} днів',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ]),
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('ГОТОВНІСТЬ',
                        style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text('${trip.readiness}%',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange)),
                  ])
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
              value: (trip.readiness.clamp(0, 100)) / 100),
        ],
      ),
    );
  }
*/
  // ------------------------

  int _daysUntil(DateTime date) {
    return date.difference(DateTime.now()).inDays;
  }

  void _showShare(BuildContext context, Trip trip) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Поділитись: ${trip.title}')));
  }

  void _showExport(BuildContext context, Trip trip) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Експорт: ${trip.title}')));
  }
}
