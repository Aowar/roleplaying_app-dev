import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/models/profile.dart';
import 'package:roleplaying_app/src/services/file_service.dart';

class ProfileService {
  static final CollectionReference _profileCollection = FirebaseFirestore.instance.collection("profiles");

  Future addProfile(Profile profile, String imagePath) async {
    DocumentReference docRef = _profileCollection.doc();
    await docRef.set({
      "id": docRef.id,
      "userId": profile.userId,
      "title": profile.title,
      "text": profile.text,
      "image": profile.image
    });
    return await FileService().uploadImage("profiles/" + docRef.id, imagePath, "profile_pic");
  }

  Future updateProfile(Profile profile) async {
    _profileCollection.doc(profile.id).update(profile.toMap());
  }

  ///Getting list stream of profiles where id of current user = user id in profile
  Stream<List<Profile>> readProfiles(String userId) =>
      FirebaseFirestore.instance.collection("profiles").where("userId", isEqualTo: userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Profile.fromJson(doc.data())).toList()
  );

  Future<Profile> getProfile(String profileId) async {
    DocumentReference docRef = _profileCollection.doc(profileId);
    return await docRef.get().then((value) {
      return Profile(value.get("userId"), value.get("title"), value.get("text"), value.get("image"));
    });
  }
}