import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  late String userId;
  late String title;
  late String text;

  Profile(this.userId,this.title, this.text);

  Profile.fromJson(Map<String, dynamic> data) {
    userId = data['userId'];
    title = data['title'];
    text = data['text'];
  }

  @override
  List<Object?> get props => [userId, title, text];

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "title": title,
      "text": text
    };
  }
}