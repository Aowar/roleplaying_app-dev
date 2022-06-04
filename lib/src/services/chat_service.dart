import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/services/file_service.dart';

class ChatService {
  final CollectionReference _chatCollection = FirebaseFirestore.instance.collection("chats");

  Future addChat(Chat chat, [String? imagePath]) async {
    DocumentReference docRef = _chatCollection.doc();
    if (!chat.isPrivate) {
      await FileService().uploadImage("chats/" + docRef.id, imagePath!, chat.image);
    }
    await docRef.set({
      "id": docRef.id,
      "usersId": chat.usersId,
      "organizerId": chat.organizerId,
      "title": chat.title,
      "description": chat.description,
      "image": chat.image,
      "isPrivate": chat.isPrivate,
      "profilesPatterns": chat.profilesPatterns,
      "approvedProfiles": chat.approvedProfiles
    });
    if (chat.isPrivate) {
      chat.id = docRef.id;
      return chat;
    }
  }

  Future updateChat(Chat chat) async {
    await _chatCollection.doc(chat.id).update(chat.toMap());
  }

  Future addNewUserInChat(Chat chat, String userId) async {
    DocumentReference docRef = _chatCollection.doc(chat.id);
    if (!chat.usersId.contains(userId)) {
      chat.usersId.add(userId);
    }
    await docRef.update(chat.toMap());
  }

  Future deleteUserFromChat(Chat chat, String userId) async {
    List listOfUsers = List.from(chat.usersId);
    listOfUsers.removeWhere((element) => element == userId);
    chat.usersId = listOfUsers;
    await updateChat(chat);
  }

  Future deleteChat(String chatId) async {
    DocumentReference docRef = _chatCollection.doc(chatId);
    await docRef.collection("messages").get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
    await docRef.collection("rolePlayQueue").get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });

    return await docRef.delete();
  }

  Future deleteApprovedProfile(String chatId, String profileId) async {
    Chat chat = await FirebaseFirestore.instance.collection("chats").doc(chatId).get().then((value) => Chat.fromJson(value.data()!));
    chat.approvedProfiles!.remove(profileId);
    updateChat(chat);
  }

  Future addProfilePattern(String chatId, String profileId) async {
    Chat chat = await getChat(chatId);
    if(chat.profilesPatterns != null) {
      chat.profilesPatterns!.add(profileId);
    } else {
      List list = [profileId];
      chat.profilesPatterns = list;
    }
    updateChat(chat);
  }

  Future deleteProfilePattern(String chatId, String profileId) async {
    Chat chat = await getChat(chatId);
    List listOfPatterns = List.from(chat.profilesPatterns!);
    listOfPatterns.remove(profileId);
    chat.profilesPatterns = listOfPatterns;
    await updateChat(chat);
  }

  Future addApprovedProfiles(String chatId, List approvedProfiles) async {
    _chatCollection.doc(chatId).update({
      "approvedProfiles": approvedProfiles
    });
  }

  Future<bool> isPrivateChatExists(List<String> users) async {
    bool exists = false;
    Function eq = const ListEquality().equals;
    await _chatCollection.where("isPrivate", isEqualTo: true).get().then((value) {
      exists = value.docs.any((element) {
        if (eq(users, element.get("usersId"))) {
          return true;
        }
        return false;
      });
    });
    return exists;
  }

  Future<Chat> getChat(String chatId) async {
    DocumentReference docRef =  _chatCollection.doc(chatId);
    return await docRef.get().then((value) {
      Chat chat = Chat(
          usersId: value.get("usersId"),
          organizerId: value.get("organizerId"),
          title: value.get("title"),
          description: value.get("description"),
          image: value.get("image"),
          isPrivate: value.get('isPrivate'),
          profilesPatterns: value.get('profilesPatterns'),
          approvedProfiles: value.get('approvedProfiles')
      );
      chat.id = value.get("id");
      return chat;
    });
  }

  ///Getting list stream of chats
  Stream<List<Chat>> readChats() => FirebaseFirestore.instance.collection("chats").where("isPrivate", isEqualTo: false).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList()
  );

  ///Getting list stream of user chats
  Stream<List<Chat>> readUserChats(String userId) => FirebaseFirestore.instance.collection("chats").where("usersId", arrayContains: userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList()
  );

  ///Get the stream of current chat
  Stream<Chat> readChat(String chatId) => FirebaseFirestore.instance.collection("chats").doc(chatId).snapshots().map(
          (doc) => Chat.fromJson(doc.data()!));
}