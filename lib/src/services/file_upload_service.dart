import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FileUploadService {

  final storageRef = FirebaseStorage.instance.ref("users");
  final metadata = SettableMetadata(contentType: "multipart/form-data");

  FileUploadService();

  uploadImage(String folder, String imagePath, String imageName) async {
    final file = File(imagePath);
    TaskState? state;
    await storageRef.child(folder + "/" + imageName).putFile(file).then((p0) => state = p0.state);
    return state;
  }

  Future<String> getImage(String folder, String imageName) async {
    return imageName == "default_user_icon.png" ? storageRef.child(imageName).getDownloadURL() : storageRef.child(folder + "/" + imageName).getDownloadURL();
  }
}