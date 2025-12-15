import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/trip.dart';
import '../../../providers/trip_provider.dart';
import '../../../providers/expenses_provider.dart';
import '../../../providers/tasks_provider.dart';
import '../../../providers/route_provider.dart';

import '../../../theme.dart';

import 'trip_tasks_screen.dart';
import 'expenses_screen.dart';
import 'route_screen.dart';
import '../gallery/trip_gallery_screen.dart';

class TripScreen extends StatefulWidget {
  static const routeName = '/trip';
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    context.read<RouteProvider>().loadForTrip(tripId);

    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    final trip = context.watch<TripProvider>().getById(tripId);

    if (trip == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final expensesProv = context.watch<ExpensesProvider>();
    final tasksProv = context.watch<TasksProvider>();
    final routeProv = context.watch<RouteProvider>();

    final spent = expensesProv.totalForTrip(trip.id);
    final tasks = tasksProv.tasksForTrip(trip.id);
    final hasRoute = routeProv.hasRoute;

    return Scaffold(
      appBar: AppBar(title: Text(trip.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // =========================
          // HEADER
          // =========================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primarySoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 HEADER TITLE
                const Text(
                  'Період подорожі',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),

                const SizedBox(height: 8),

                // 🔹 DATES
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_fmt(trip.startDate)} — ${_fmt(trip.endDate)} • ${trip.duration} днів',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),


          const SizedBox(height: 24),

          // =========================
          // TASKS
          // =========================
          _item(
            context,
            icon: Icons.check_circle_outline,
            title: 'Завдання',
            subtitle: 'Завдань: ${tasks.length}',
            onTap: () {
              Navigator.of(context).pushNamed(
                TripTasksScreen.routeName,
                arguments: trip.id,
              );
            },
          ),

          const SizedBox(height: 12),

          // =========================
          // BUDGET
          // =========================
          _item(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Бюджет',
            subtitle:
            '${trip.currency}${spent.toStringAsFixed(0)} / ${trip.currency}${trip.budget.toStringAsFixed(0)}',
            onTap: () {
              Navigator.of(context).pushNamed(
                ExpensesScreen.routeName,
                arguments: trip.id,
              );
            },
          ),

          const SizedBox(height: 12),

          // =========================
          // ROUTE
          // =========================
          _item(
            context,
            icon: Icons.map_outlined,
            title: 'Маршрут',
            subtitle:
            hasRoute ? 'Маршрут сплановано' : 'Маршрут не задано',
            onTap: () {
              Navigator.of(context).pushNamed(
                RouteScreen.routeName,
                arguments: trip.id,
              );
            },
          ),

          const SizedBox(height: 12),

          // =========================
          // GALLERY
          // =========================
          _item(
            context,
            icon: Icons.photo_library_outlined,
            title: 'Галерея',
            subtitle: 'Фото подорожі',
            onTap: () {
              Navigator.of(context).pushNamed(
                TripGalleryScreen.routeName,
                arguments: trip.id,
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================
  // UI HELPERS
  // =========================

  Widget _item(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
          '${d.month.toString().padLeft(2, '0')}.'
          '${d.year}';
}
