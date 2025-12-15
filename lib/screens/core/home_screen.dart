import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trip_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../models/trip.dart';
import '../../models/trip_status.dart';

import '../core/trip/trip_screen.dart';
import '../core/trip/create_trip_screen.dart';

import '../../theme.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TripStatus? _filter;
  bool _expensesLoaded = false;

  @override
  void initState() {
    super.initState();

    /// 🔥 ВАЖЛИВО: ініціалізація після першого рендера
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripProv = context.read<TripProvider>();
      final expensesProv = context.read<ExpensesProvider>();

      for (final trip in tripProv.trips) {
        expensesProv.loadForTrip(trip.id);
      }

      _expensesLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripProv = context.watch<TripProvider>();
    final expensesProv = context.watch<ExpensesProvider>();

    final trips = tripProv.trips;

    final visibleTrips = _filter == null
        ? trips
        : trips
        .where((t) =>
    getTripStatus(t.startDate, t.endDate) == _filter)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мої подорожі'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primarySoft,
              child: const Text(
                'О',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              onChanged: tripProv.filter,
              decoration: const InputDecoration(
                hintText: 'Пошук подорожей...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip(null, 'ALL'),
                  _chip(TripStatus.ongoing, 'ONGOING'),
                  _chip(TripStatus.upcoming, 'UPCOMING'),
                  _chip(TripStatus.past, 'PAST'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: visibleTrips.isEmpty
                  ? const Center(child: Text('Немає подорожей'))
                  : ListView.separated(
                itemCount: visibleTrips.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final trip = visibleTrips[i];
                  final spent =
                  expensesProv.totalForTrip(trip.id);

                  return _card(context, trip, spent);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(CreateTripScreen.routeName),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _chip(TripStatus? s, String label) {
    final selected = _filter == s;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppTheme.primarySoft,
        labelStyle: TextStyle(
          color: selected
              ? AppTheme.primary
              : AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => setState(() => _filter = s),
      ),
    );
  }

  Widget _card(BuildContext context, Trip trip, double spent) {
    final status = getTripStatus(trip.startDate, trip.endDate);
    final percent = trip.budget > 0
        ? (spent / trip.budget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).pushNamed(
            TripScreen.routeName,
            arguments: trip.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trip.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'edit', child: Text('Редагувати')),
                      PopupMenuItem(
                          value: 'delete', child: Text('Видалити')),
                    ],
                    onSelected: (v) {
                      if (v == 'edit') {
                        Navigator.of(context).pushNamed(
                          CreateTripScreen.routeName,
                          arguments: trip,
                        );
                      } else {
                        context
                            .read<TripProvider>()
                            .deleteTrip(trip.id);
                      }
                    },
                  )
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_fmt(trip.startDate)} — ${_fmt(trip.endDate)} • ${trip.duration} days',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  _status(status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${trip.currency}${spent.toStringAsFixed(0)} / ${trip.currency}${trip.budget.toStringAsFixed(0)}',
                style:
                const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              _progress(percent, AppTheme.primary),
              const SizedBox(height: 10),
              _progress(percent, AppTheme.border),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progress(double value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        minHeight: 3,
        value: value,
        color: color,
        backgroundColor: AppTheme.border,
      ),
    );
  }

  Widget _status(TripStatus s) {
    final data = switch (s) {
      TripStatus.ongoing => ('ONGOING', AppTheme.success),
      TripStatus.upcoming => ('UPCOMING', AppTheme.primary),
      TripStatus.past => ('PAST', AppTheme.textMuted),
    };

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: data.$2.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: data.$2.withOpacity(0.25)),
      ),
      child: Text(
        data.$1,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: data.$2,
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
          '${d.month.toString().padLeft(2, '0')}.'
          '${d.year}';
}
