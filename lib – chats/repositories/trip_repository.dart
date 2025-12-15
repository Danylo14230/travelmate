import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/trip.dart';

class TripRepository {
  final CollectionReference _trips =
  FirebaseFirestore.instance.collection('trips');

  Stream<List<Trip>> getTrips() {
    return _trips
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
    });
  }

  Future<DocumentReference> addTrip(Trip trip) async {
    return await _trips.add(trip.toFirestore());
  }



  Future<void> updateTrip(Trip trip) async {
    await _trips.doc(trip.id).update(trip.toFirestore());
  }

  Future<void> deleteTrip(String id) async {
    await _trips.doc(id).delete();
  }

  Future<String> uploadImage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance
        .ref()
        .child('trip_covers/$fileName');

    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
