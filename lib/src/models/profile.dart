import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  late String id;
  late String userId;
  late String title;
  late String text;
  late Map<String, String>? additionalFields;

  Profile(this.userId, this.title, this.text, this.additionalFields);

  Profile.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    userId = data['userId'];
    title = data['title'];
    text = data['text'];
    additionalFields = data['additionalFields'];
  }

  @override
  List<Object?> get props => [userId, title, text];

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "title": title,
      "text": text,
      "additionalFields": additionalFields,
      "id": id
    };
  }
}