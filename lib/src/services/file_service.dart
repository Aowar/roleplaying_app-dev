import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class FileService {

  final storageRef = FirebaseStorage.instance.ref();
  final metadata = SettableMetadata(contentType: "multipart/form-data");

  FileService();

  uploadImage(String folder, String imagePath, String imageName) async {
    final file = File(imagePath);
    TaskState? state;
    await storageRef.child(folder + "/" + imageName).putFile(file).then((p0) => state = p0.state);
    return state;
  }

  Future<String> getUserImage(String folder, String imageName) async {
    final _storageRef = storageRef.child("users");
    return imageName == "default_user_icon.png" ? _storageRef.child(imageName).getDownloadURL() : _storageRef.child(folder + "/" + imageName).getDownloadURL();
  }

  Future<String> getChatImage(String folder, String imageName) async {
    final _storageRef = storageRef.child("chats");
    return _storageRef.child(folder).child(imageName).getDownloadURL();
  }

  Future<String> getProfileImage(String folder, String imageName) async {
    final _storageRef = storageRef.child("profiles");
    return _storageRef.child(folder).child(imageName).getDownloadURL();
  }
}