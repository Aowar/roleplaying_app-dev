import 'dart:developer';
import 'dart:io';

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

  Future<String> getChatImage(String folder, String imageName, bool isPrivate) async {
    Reference _storageRef;
    if (isPrivate && imageName == "default_image.png") {
      _storageRef = storageRef;
      return _storageRef.child("chats").child(imageName).getDownloadURL();
    } else {
      _storageRef = storageRef.child("chats");
      return _storageRef.child(folder).child(imageName).getDownloadURL();
    }
  }

  Future<String> getProfileImage(String folder, String imageName) async {
    final _storageRef = storageRef.child("profiles");
    String downloadResult;
    try {
      downloadResult = await _storageRef.child(folder).child(imageName).getDownloadURL();
    } catch(error) {
      log(error.toString(), name: "Error while download");
      downloadResult = "error";
    }
    return downloadResult;
  }

  deleteImage(String folder, String imageName) async {
    await storageRef.child(folder + "/" + imageName).delete();
  }
}