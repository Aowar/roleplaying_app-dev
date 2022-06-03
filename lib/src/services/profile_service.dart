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
      "image": profile.image,
      "isPattern": profile.isPattern,
      "chatId": profile.chatId,
      "isApproved": profile.approvementState
    });
    profile.id = docRef.id;
    await FileService().uploadImage("profiles/" + docRef.id, imagePath, "profile_pic");
    return profile.id;
  }

  Future updateProfile(Profile profile) async {
    await _profileCollection.doc(profile.id).update(profile.toMap());
  }

  Future deleteProfile(String profileId) async {
    await _profileCollection.doc(profileId).delete();
    FileService().deleteImage("profiles/" + profileId, "profile_pic");
  }

  ///Getting list stream of profiles where id of current user = user id in profile
  Stream<List<Profile>> readProfiles(String userId) =>
      FirebaseFirestore.instance.collection("profiles").where("userId", isEqualTo: userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Profile.fromJson(doc.data())).toList()
  );

  Stream<List<Profile>> readProfilesPatterns(String chatId) =>
      FirebaseFirestore.instance.collection("profiles").where("chatId", isEqualTo: chatId).where("isPattern", isEqualTo: true).snapshots().map(
              (snapshot) => snapshot.docs.map((doc) => Profile.fromJson(doc.data())).toList()
      );

  Future<Profile> getProfile(String profileId) async {
    DocumentReference docRef = _profileCollection.doc(profileId);
    return await docRef.get().then((value) {
      return Profile(
          userId: value.get("userId"),
          title: value.get("title"),
          text: value.get("text"),
          image: value.get("image"),
          isPattern: value.get("isPattern"),
          chatId: value.get("chatId"),
          approvementState: value.get("isApproved")
      );
    });
  }

  Future<List<Profile>> getProfilesForChat(String userId, String chatId) async {
    List<Profile> list = [];
    await _profileCollection.where("userId", isEqualTo: userId).where("chatId", isEqualTo: chatId).get().then(<Profile>(value) {
      for(int i = 0; i < value.docs.length; i++) {
        list.add(value.docs[i].data());
      }
    });
    return list;
  }
}