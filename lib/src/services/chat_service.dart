import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';

class ChatService {
  final CollectionReference _chatCollection = FirebaseFirestore.instance.collection("chats");

  Future addChat(Chat chat) async {
    DocumentReference docRef = _chatCollection.doc();
    return await docRef.set({
      chat.id = docRef.id,
      chat.toMap()
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

  Future deleteChat(String chatId) async {
    DocumentReference docRef = _chatCollection.doc(chatId);
    await docRef.collection("messages").get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
    return await docRef.delete();
  }

  Future<Chat> getChat(String chatId) async {
    DocumentReference docRef =  _chatCollection.doc(chatId);
    return await docRef.get().then((value) {
      return Chat(value.get("usersId"), value.get("organizerId"), value.get("title"), value.get("description"), value.get("image"));
    });
  }

  ///Getting list stream of chats
  Stream<List<Chat>> readChats() => FirebaseFirestore.instance.collection("chats").snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList()
  );

  ///Getting list stream of user chats
  Stream<List<Chat>> readUserChats(String userId) => FirebaseFirestore.instance.collection("chats").where("usersId", arrayContains: userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList()
  );
}