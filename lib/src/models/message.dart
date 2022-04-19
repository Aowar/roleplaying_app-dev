import 'package:equatable/equatable.dart';

class Message extends Equatable {
  late String id;
  late String authorId;
  late String text;

  Message(this.authorId, this.text);

  Message.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    authorId = data['authorId'];
    text = data['text'];
  }

  @override
  List<Object?> get props => [id, authorId, text];

  Map<String, dynamic> toMap() {
    return {
      "authorId": authorId,
      "text": text
    };
  }
}