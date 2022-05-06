import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';

class ChatService {
  final CollectionReference _chatCollection = FirebaseFirestore.instance.collection("chats");

  Future addChat(Chat chat) async {
    DocumentReference docRef = _chatCollection.doc();
    return await docRef.set({
      'title': chat.title,
      'description': chat.description,
      'usersId': chat.usersId,
      'organizerId': chat.organizerId,
      'id': docRef.id
    });
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

  Future deleteChat(Chat chat) async {
    DocumentReference docRef = _chatCollection.doc(chat.id);
    await docRef.collection("messages").get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
    return await docRef.delete();
  }

  Future<Chat> getChat(Chat chat) async {
    DocumentReference docRef =  _chatCollection.doc(chat.id);
    return await docRef.get().then((value) {
      if (value.exists) {
        return Chat(value.get("usersId"), value.get("organizerId"), value.get("title"), value.get("description"));
      }
      else {
        return chat;
      }
    });
  }

  ///Getting list stream of chats
  static Stream<List<Chat>> readChats() => FirebaseFirestore.instance.collection("chats").snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList()
  );

  ///Getting list stream of user chats
  static Stream<List<Chat>> readUserChats(String userId) => FirebaseFirestore.instance.collection("chats").where("usersId", arrayContains: userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList()
  );

  CollectionReference getCollection() {
    return _chatCollection;
  }
}