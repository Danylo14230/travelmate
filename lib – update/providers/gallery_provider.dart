// lib/providers/gallery_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../models/trip_photo.dart';

class GalleryProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  List<TripPhoto> _photos = [];
  List<TripPhoto> get photos => _photos;

  bool loading = false;

  void listen(String tripId) {
    _db
        .collection('trips')
        .doc(tripId)
        .collection('gallery')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      _photos = snap.docs.map((d) => TripPhoto.fromFirestore(d)).toList();
      notifyListeners();
    });
  }

  Future<void> addPhoto(String tripId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    loading = true;
    notifyListeners();

    final ref = _storage
        .ref('trips/$tripId/gallery/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(File(picked.path));
    final url = await ref.getDownloadURL();

    await _db
        .collection('trips')
        .doc(tripId)
        .collection('gallery')
        .add({
      'url': url,
      'ownerId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    loading = false;
    notifyListeners();
  }
}
