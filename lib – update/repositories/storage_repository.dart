import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  final String uid;
  StorageRepository(this.uid);

  Future<String> uploadTripImage(String tripId, File file) async {
    final ref = FirebaseStorage.instance
        .ref('users/$uid/trips/$tripId/cover.jpg');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
