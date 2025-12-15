import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip.dart';
import '../repositories/chat_repository.dart';

class TripProvider extends ChangeNotifier {
  final CollectionReference _tripsCollection =
  FirebaseFirestore.instance.collection('trips');

  final ChatRepository _chatRepo = ChatRepository();

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
        .orderBy('startDate', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
        _allTrips =
            snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
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

  // ===== CRUD =====

  Future<void> addTrip(Trip trip) async {
    await _tripsCollection.add(trip.toFirestore());
  }



  Future<void> updateTrip(Trip trip) async {
    await _tripsCollection
        .doc(trip.id)
        .update(trip.toFirestore());
  }

  Future<void> deleteTrip(String id) async {
    await _tripsCollection.doc(id).delete();
  }

  // ===== FILTER =====

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
