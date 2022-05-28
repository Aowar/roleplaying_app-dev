import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/bloc/auth/auth_bloc.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/services/file_service.dart';

class ChatService {
  final CollectionReference _chatCollection = FirebaseFirestore.instance.collection("chats");

  Future addChat(Chat chat, String imagePath) async {
    DocumentReference docRef = _chatCollection.doc();
    await docRef.set({
      "id": docRef.id,
      "usersId": chat.usersId,
      "organizerId": chat.organizerId,
      "title": chat.title,
      "description": chat.description,
      "image": chat.image
    });
    return await FileService().uploadImage("chats/" + docRef.id, imagePath, "chat_picture");
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
      Chat chat = Chat(value.get("usersId"), value.get("organizerId"), value.get("title"), value.get("description"), value.get("image"));
      chat.id = value.get("id");
      return chat;
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