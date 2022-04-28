import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  late String id;
  late String authorId;
  late String text;
  late Timestamp creationDate;

  Message(this.authorId, this.text){
    creationDate = Timestamp.now();
  }

  Message.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    authorId = data['authorId'];
    text = data['text'];
    creationDate = data['creationDate'];
  }

  @override
  List<Object?> get props => [id, authorId, text, creationDate];

  Map<String, dynamic> toMap() {
    return {
      "authorId": authorId,
      "text": text,
      "creationDate": creationDate
    };
  }
}