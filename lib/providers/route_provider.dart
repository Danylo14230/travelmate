import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/route_event.dart';

class RouteProvider extends ChangeNotifier {
  final List<RouteEvent> _events = [];
  StreamSubscription? _sub;
  bool _isLoading = false;

  List<RouteEvent> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;

  bool get hasRoute => _events.isNotEmpty;

  void loadForTrip(String tripId) {
    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('route')
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
      _events
        ..clear()
        ..addAll(snapshot.docs.map(RouteEvent.fromFirestore));

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addEvent(String tripId, RouteEvent event) async {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('route')
        .add(event.toFirestore());
  }

  Future<void> updateEvent(String tripId, RouteEvent event) async {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('route')
        .doc(event.id)
        .update(event.toFirestore());
  }

  Future<void> deleteEvent(String tripId, String eventId) async {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('route')
        .doc(eventId)
        .delete();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
