import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  late String id;
  late String userId;
  late String title;
  late String text;
  late String image;

  Profile(this.userId, this.title, this.text, this.image);

  Profile.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    userId = data['userId'];
    title = data['title'];
    text = data['text'];
    image = data['image'];
  }

  @override
  List<Object?> get props => [id, userId, title, text, image];

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "title": title,
      "text": text,
      "id": id,
      "image": image
    };
  }
}