import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/gallery_image.dart';

class GalleryRepository {
  static const String _bucket = 'trip-gallery';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // ===========================================================
  // DEBUG HELPERS
  // ===========================================================

  void _log(String msg) {
    if (kDebugMode) {
      debugPrint('🖼️ [GalleryRepository] $msg');
    }
  }

  void _logError(String msg, Object e, [StackTrace? s]) {
    debugPrint('❌ [GalleryRepository] $msg');
    debugPrint('❌ ERROR: $e');
    if (s != null) debugPrint('❌ STACK: $s');
  }

  // ===========================================================
  // STORAGE CHECK (ДУЖЕ ВАЖЛИВО)
  // ===========================================================

  Future<void> assertStorageAvailable() async {
    _log('Checking Supabase storage access...');

    try {
      final res = await _supabase.storage.from(_bucket).list();
      _log('Storage OK, files count: ${res.length}');
    } on StorageException catch (e, s) {
      _logError(
        'Storage NOT available (bucket/policy/anon key problem)',
        e,
        s,
      );
      rethrow;
    }
  }

  // ===========================================================
  // ADD PHOTO
  // ===========================================================

  Future<void> addPhoto(String tripId) async {
    try {
      // 1️⃣ Перевірка доступу до Storage
      await assertStorageAvailable();

      // 2️⃣ Pick image
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) {
        _log('Image picking cancelled');
        return;
      }

      // 3️⃣ Bytes
      final Uint8List bytes = await picked.readAsBytes();
      final ext = picked.mimeType?.split('/').last ?? 'jpg';

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final storagePath = 'trips/$tripId/$fileName';

      _log('Uploading file → $_bucket/$storagePath');

      // 4️⃣ Upload
      await _supabase.storage.from(_bucket).uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          cacheControl: '3600',
        ),
      );

      // 5️⃣ Public URL
      final url =
      _supabase.storage.from(_bucket).getPublicUrl(storagePath);

      _log('Uploaded OK, public URL: $url');

      // 6️⃣ Save metadata to Firestore
      await _firestore.collection('trip-gallery').add({
        'tripId': tripId,
        'url': url,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _log('Firestore metadata saved');
    } on StorageException catch (e, s) {
      _logError('Supabase Storage error during addPhoto', e, s);
      rethrow;
    } catch (e, s) {
      _logError('Unknown error during addPhoto', e, s);
      rethrow;
    }
  }

  // ===========================================================
  // TRIP GALLERY
  // ===========================================================

  Stream<List<GalleryImage>> photosStream(String tripId) {
    return _firestore
        .collection('trip-gallery')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snap) {
      final list =
      snap.docs.map(GalleryImage.fromFirestore).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ===========================================================
  // ALL GALLERY
  // ===========================================================

  Stream<List<GalleryImage>> allGallery() {
    return _firestore
        .collection('trip-gallery')
        .snapshots()
        .map(
          (snap) =>
          snap.docs.map(GalleryImage.fromFirestore).toList(),
    );
  }

  // ===========================================================
  // DELETE PHOTO (БЕЗ 404)
  // ===========================================================

  Future<void> deletePhoto(GalleryImage img) async {
    try {
      _log('Deleting photo ${img.id}');

      // 1️⃣ Delete Firestore doc
      await _firestore
          .collection('trip-gallery')
          .doc(img.id)
          .delete();

      // 2️⃣ Extract storage path SAFELY
      final uri = Uri.parse(img.url);

      final path = uri.pathSegments
          .skipWhile((s) => s != _bucket)
          .skip(1)
          .join('/');

      if (path.isEmpty) {
        throw StateError('Cannot extract storage path from URL');
      }

      _log('Removing storage file: $_bucket/$path');

      // 3️⃣ Remove from Supabase
      await _supabase.storage.from(_bucket).remove([path]);

      _log('Photo deleted successfully');
    } on StorageException catch (e, s) {
      _logError('Supabase Storage error during deletePhoto', e, s);
      rethrow;
    } catch (e, s) {
      _logError('Unknown error during deletePhoto', e, s);
      rethrow;
    }
  }
}
