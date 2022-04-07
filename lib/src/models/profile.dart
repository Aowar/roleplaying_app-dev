import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String userId;
  String title;
  String text;

  Profile(this.userId,this.title, this.text);

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