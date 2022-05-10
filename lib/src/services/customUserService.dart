import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/models/customUserModel.dart';

class CustomUserService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection("users");

  Future addCustomUser(CustomUserModel customUserModel) async {
    DocumentReference docRef = _usersCollection.doc();
    return await docRef.set({
      'userId': customUserModel.idUser,
      'nickName' : customUserModel.nickName
    });
  }

  Future updateCustomUser(CustomUserModel customUserModel) async {
    _usersCollection.doc(customUserModel.idUser).update(customUserModel.toMap());
  }
}