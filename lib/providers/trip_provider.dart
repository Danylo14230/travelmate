import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripProvider extends ChangeNotifier {
  final CollectionReference _tripsCollection =
  FirebaseFirestore.instance.collection('trips');

  List<Trip> _allTrips = [];
  List<Trip> _visibleTrips = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Trip> get trips => _visibleTrips;

  TripProvider() {
    _listenToTrips();
  }

  void _listenToTrips() {
    _isLoading = true;
    notifyListeners();

    _tripsCollection
        .orderBy('startDate')
        .snapshots()
        .listen(
          (snapshot) {
        _allTrips =
            snapshot.docs.map((d) => Trip.fromFirestore(d)).toList();
        _visibleTrips = List.of(_allTrips);
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ===== CRUD (НЕ ЧІПАВ) =====

  Future<void> addTrip(Trip trip) async {
    await _tripsCollection.add(trip.toFirestore());
  }

  Future<void> updateTrip(Trip trip) async {
    await _tripsCollection.doc(trip.id).update(trip.toFirestore());
  }

  Future<void> deleteTrip(String tripId) async {
    final db = FirebaseFirestore.instance;
    final supabase = Supabase.instance.client;

    final tripRef = db.collection('trips').doc(tripId);

    // ===== 1. TASKS =====
    await _deleteSubcollection(tripRef.collection('tasks'));

    // ===== 2. EXPENSES =====
    await _deleteSubcollection(tripRef.collection('expenses'));

    // ===== 3. ROUTE =====
    await _deleteSubcollection(tripRef.collection('route'));

    // ===== 4. GALLERY (Firestore + Supabase) =====
    final gallerySnap = await db
        .collection('trip-gallery')
        .where('tripId', isEqualTo: tripId)
        .get();

    for (final doc in gallerySnap.docs) {
      final data = doc.data();
      final url = data['url'] as String?;

      if (url != null && url.isNotEmpty) {
        try {
          final uri = Uri.parse(url);
          final path =
              uri.path.split('/object/public/trip-gallery/').last;

          await supabase
              .storage
              .from('trip-gallery')
              .remove([path]);
        } catch (_) {
          // файл міг вже бути видалений — не критично
        }
      }

      await doc.reference.delete();
    }

    // ===== 5. DELETE TRIP =====
    await tripRef.delete();

    notifyListeners();
  }

  Future<void> _deleteSubcollection(CollectionReference col) async {
    final snap = await col.get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }


  // ===== FILTER (НЕ ЧІПАВ) =====

  void filter(String query) {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      _visibleTrips = List.of(_allTrips);
    } else {
      _visibleTrips = _allTrips.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.destinations.any((d) => d.toLowerCase().contains(q));
      }).toList();
    }

    notifyListeners();
  }

  Trip? getById(String id) {
    try {
      return _allTrips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
