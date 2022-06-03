import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  late String id;
  late List usersId;
  late String organizerId;
  late String title;
  late String description;
  late String image;
  late bool isPrivate;
  late List? profilesPatterns = [];

  Chat({required this.usersId, required this.organizerId, required this.title, required this.description, required this.image, this.isPrivate = false, this.profilesPatterns});

  Chat.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    usersId = data['usersId'];
    organizerId = data['organizerId'];
    title = data['title'];
    description = data['description'];
    image = data['image'];
    isPrivate = data['isPrivate'];

  }

  @override
  List<Object?> get props => [id, usersId, organizerId, title, description, image, isPrivate, profilesPatterns];

  Map<String, dynamic> toMap() {
    return {
      "usersId": usersId,
      "organizerId": organizerId,
      "title": title,
      "description": description,
      "image": image,
      "isPrivate": isPrivate,
      "profilesPatterns": profilesPatterns
    };
  }
}