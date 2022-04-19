import 'package:firebase_database/firebase_database.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/message.dart';

class MessageService {
  final Chat chat;
  late DatabaseReference messageCollection;
  MessageService(this.chat) {
    messageCollection = FirebaseDatabase.instance.ref("chat/" + chat.id).child("messages");
  }

  Future addMessage(Message message) async {
    DatabaseReference docRef = messageCollection.push();
    return await docRef.set({
      'authorId': message.authorId,
      'text': message.text,
      'id': docRef.key
    });
  }
}