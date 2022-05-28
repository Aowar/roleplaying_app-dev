import 'package:cloud_firestore/cloud_firestore.dart';
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
      "id": docRef.id,
      "authorId": message.authorId,
      "text": message.text,
      "creationDate": message.creationDate
    });
  }

  ///Getting list stream of messages
  Stream<List<Message>> readMessages() =>
    FirebaseFirestore.instance.collection("chats").doc(chat.id).collection("messages").orderBy('creationDate', descending: false).snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList());
}