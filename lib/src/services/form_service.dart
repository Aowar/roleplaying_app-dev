import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/models/profile.dart';

class FormService {
  final CollectionReference _profileCollection = FirebaseFirestore.instance.collection("profiles");

  Future addOrUpdateProfile(Profile form) async {
    return await _profileCollection.doc().set(form.toMap());
  }

  getProfiles(String userId) {
    return _profileCollection.doc().get();
  }
}