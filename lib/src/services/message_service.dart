import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/message.dart';

class MessageService {
  final Chat chat;
  late CollectionReference messageCollection;
  MessageService(this.chat) {
    messageCollection = FirebaseFirestore.instance.collection("chats");
  }

  Future addMessage(Message message) async {
    DocumentReference docRef = messageCollection.doc(chat.id).collection("messages").doc();
    return await docRef.set({
      'authorId': message.authorId,
      'text': message.text,
      'id': docRef.id,
      'creationDate': message.creationDate
    });
  }

  CollectionReference getCollection() {
    return messageCollection;
  }
}