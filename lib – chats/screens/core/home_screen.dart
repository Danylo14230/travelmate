import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../models/trip.dart';
import '../core/trip/trip_screen.dart';
import '../core/trip/create_trip_screen.dart';
import '../../widgets/app_button.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProv = context.watch<TripProvider>();
    final trips = tripProv.trips;

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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                onChanged: (q) => tripProv.filter(q),
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

              Row(
                children: [
                  Expanded(child: Container()),
                  AppButton(
                    label: '+ Нова подорож',
                    onPressed: () async {
                      final created = await Navigator.of(context)
                          .pushNamed(CreateTripScreen.routeName);

                      if (created is Trip) {
                        context.read<TripProvider>().addTrip(created);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Expanded(
                child: trips.isEmpty
                    ? const Center(child: Text('Немає подорожей'))
                    : ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (ctx, i) => _tripCard(context, trips[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tripCard(BuildContext context, Trip trip) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            TripScreen.routeName,
            arguments: trip.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      trip.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '\$${trip.budget.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Text(
                '${_format(trip.startDate)} — ${_format(trip.endDate)} • ${trip.duration} днів',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      trip.destinations.join(', '),
                      style: const TextStyle(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      final prov = context.read<TripProvider>();

                      if (v == 'edit') {
                        final result = await Navigator.of(context).pushNamed(
                          CreateTripScreen.routeName,
                          arguments: trip,
                        );

                        if (result is Trip) {
                          prov.updateTrip(result);
                        }
                      }

                      if (v == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Видалити подорож?'),
                            content: Text('Ви точно хочете видалити "${trip.title}"?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Скасувати')),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Видалити',
                                      style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          prov.deleteTrip(trip.id);
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text("Редагувати"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Видалити",
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

}
