import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FileUploadService {

  final storageRef = FirebaseStorage.instance.ref();
  final metadata = SettableMetadata(contentType: "multipart/form-data");

  FileUploadService();

  uploadImage(String folder, String imagePath, String imageName) {
    final file = File(imagePath);
    return storageRef.child(folder + "/" + imageName).putFile(file);
  }
}