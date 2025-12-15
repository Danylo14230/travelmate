import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trip_provider.dart';
import '../../models/trip.dart';
import '../../models/trip_status.dart';

import '../core/trip/trip_screen.dart';
import '../core/trip/create_trip_screen.dart';
import '../../widgets/app_button.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TripStatus? _statusFilter; // null = ALL

  @override
  Widget build(BuildContext context) {
    final tripProv = context.watch<TripProvider>();
    final trips = tripProv.trips;

    final filteredTrips = _statusFilter == null
        ? trips
        : trips
        .where((t) =>
    getTripStatus(t.startDate, t.endDate) == _statusFilter)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мої подорожі'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.blue[50],
              child: const Text('О', style: TextStyle(color: Colors.blue)),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // ===== SEARCH =====
              TextField(
                onChanged: tripProv.filter,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: '🔍 Пошук подорожей...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===== STATUS FILTER =====
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _statusChip(null, 'ALL'),
                    _statusChip(TripStatus.ongoing, 'ONGOING'),
                    _statusChip(TripStatus.upcoming, 'UPCOMING'),
                    _statusChip(TripStatus.past, 'PAST'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ===== LIST =====
              Expanded(
                child: filteredTrips.isEmpty
                    ? const Center(child: Text('Немає подорожей'))
                    : ListView.builder(
                  itemCount: filteredTrips.length,
                  itemBuilder: (ctx, i) =>
                      _tripCard(context, filteredTrips[i]),
                ),
              ),
            ],
          ),
        ),
      ),

      // ===== ADD =====
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(CreateTripScreen.routeName),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ===== STATUS CHIP =====
  Widget _statusChip(TripStatus? status, String label) {
    final selected = _statusFilter == status;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _statusFilter = status),
      ),
    );
  }

  // ===== TRIP CARD =====
  Widget _tripCard(BuildContext context, Trip trip) {
    final percent = trip.budget > 0
        ? (trip.spent / trip.budget).clamp(0.0, 1.0)
        : 0.0;

    final budgetColor = percent < 0.7
        ? Colors.green
        : percent < 1
        ? Colors.orange
        : Colors.red;

    final status = getTripStatus(trip.startDate, trip.endDate);



    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
              // ===== TITLE + STATUS =====
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trip.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // STATUS BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tripStatusColor(status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tripStatusIcon(status),
                          size: 14,
                          color: tripStatusColor(status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tripStatusLabel(status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: tripStatusColor(status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ===== DATES =====
              Text(
                '${_format(trip.startDate)} — ${_format(trip.endDate)} • ${trip.duration} days',
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 10),

              // ===== BUDGET =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${trip.spent.toStringAsFixed(0)} / \$${trip.budget.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${(percent * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: budgetColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              LinearProgressIndicator(
                value: percent,
                color: budgetColor,
                backgroundColor: budgetColor.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== DATE FORMAT =====
  String _format(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}
