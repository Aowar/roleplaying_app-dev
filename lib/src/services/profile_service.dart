import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/models/profile.dart';

import '../bloc/auth/auth_bloc.dart';

class ProfileService {
  static final CollectionReference _profileCollection = FirebaseFirestore.instance.collection("profiles");

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

  ///Getting list stream of profiles where id of current user = user id in profile
  static Stream<List<Profile>> readProfiles(String userId) =>
      FirebaseFirestore.instance.collection("profiles").where("userId", isEqualTo: userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Profile.fromJson(doc.data())).toList()
  );

  Future<Profile> getProfile(String profileId) async {
    DocumentReference docRef =  _profileCollection.doc(profileId);
    return await docRef.get().then((value) {
      return Profile(value.get("userId"), value.get("title"), value.get("text"));
    });
  }
}