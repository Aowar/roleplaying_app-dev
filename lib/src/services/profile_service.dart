import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/models/profile.dart';

class ProfileService {
  final CollectionReference _profileCollection = FirebaseFirestore.instance.collection("profiles");

  Future addProfile(Profile profile) async {
    DocumentReference docRef = _profileCollection.doc();
    return await docRef.set({
      'title': profile.title,
      'text': profile.text,
      'userId': profile.userId,
      'id': docRef.id
    });
  }

  Future updateProfile(Profile profile) async {
    _profileCollection.doc(profile.id).update(profile.toMap());
  }
}