import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/models/chat.dart';

class ChatService {
  final CollectionReference _chatCollection = FirebaseFirestore.instance.collection("chats");

  Future addChat(Chat chat) async {
    DocumentReference docRef = _chatCollection.doc();
    return await docRef.set({
      'title': chat.title,
      'description': chat.description,
      'usersId': chat.usersId,
      'organizerId': chat.organizatorId,
      'id': docRef.id
    });
  }

  Future updateChat(Chat chat) async {
    _chatCollection.doc(chat.id).update(chat.toMap());
  }

  CollectionReference getCollection() {
    return _chatCollection;
  }
}