import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/gallery_image.dart';

class GalleryRepository {
  final _firestore = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  Future<void> addPhoto(String tripId) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    // ✅ ЄДИНИЙ КОРЕКТНИЙ ВАРІАНТ ДЛЯ WEB + MOBILE
    final Uint8List bytes = await picked.readAsBytes();

    final ext = picked.name.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storagePath = 'trips/$tripId/$fileName';

    await _supabase.storage
        .from('trip-gallery')
        .uploadBinary(
      storagePath,
      bytes,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: false,
      ),
    );

    final url = _supabase.storage
        .from('trip-gallery')
        .getPublicUrl(storagePath);

    await _firestore.collection('trip-gallery').add({
      'tripId': tripId,
      'url': url,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<GalleryImage>> photosStream(String tripId) {
    return _firestore
        .collection('trip-gallery')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map(GalleryImage.fromFirestore)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<GalleryImage>> allGallery() {
    return _firestore
        .collection('trip-gallery')
        .snapshots()
        .map((snap) =>
        snap.docs.map(GalleryImage.fromFirestore).toList());
  }

  Future<void> deletePhoto(GalleryImage img) async {
    await _firestore
        .collection('trip-gallery')
        .doc(img.id)
        .delete();

    final uri = Uri.parse(img.url);
    final path =
        uri.path.split('/object/public/trip-gallery/').last;

    await _supabase.storage
        .from('trip-gallery')
        .remove([path]);
  }
}
