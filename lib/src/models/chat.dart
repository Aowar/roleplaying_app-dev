import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  late String id;
  late List usersId;
  late String organizerId;
  late String title;
  late String description;
  late String image;

  Chat(this.usersId, this.organizerId, this.title, this.description, this.image);

  Chat.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    usersId = data['usersId'];
    organizerId = data['organizerId'];
    title = data['title'];
    description = data['description'];
    image = data['image'];
  }

  @override
  List<Object?> get props => [usersId, organizerId, title, description, image];

  Map<String, dynamic> toMap() {
    return {
      "usersId": usersId,
      "organizerId": organizerId,
      "title": title,
      "description": description,
      "image": image
    };
  }
}