import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roleplaying_app/src/models/customUserModel.dart';

class CustomUserService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection("users");

  Future addCustomUser(CustomUserModel customUserModel) async {
    DocumentReference docRef = _usersCollection.doc(customUserModel.idUser);
    await docRef.set({
      'userId': customUserModel.idUser,
      'nickName' : customUserModel.nickName
    });
  }

  Future updateCustomUser(CustomUserModel customUserModel) async {
    return await _usersCollection.doc(customUserModel.idUser).update(customUserModel.toMap());
  }

  Future<bool> collectionContainsUser(String userId) async {
    bool exists = false;
    await _usersCollection.doc(userId).get().then((value) => exists = value.exists);
    return exists;
  }
}