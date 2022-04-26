import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  late String id;
  late List usersId;
  late String organizatorId;
  late String title;
  late String description;

  Chat(this.usersId, this.organizatorId, this.title, this.description);

  Chat.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    usersId = data['usersId'];
    organizatorId = data['organizerId'];
    title = data['title'];
    description = data['description'];
  }

  @override
  List<Object?> get props => [usersId, organizatorId, title, description];

  Map<String, dynamic> toMap() {
    return {
      "usersId": usersId,
      "organizerId": organizatorId,
      "title": title,
      "description": description
    };
  }
}