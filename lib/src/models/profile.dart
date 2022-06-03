import 'package:equatable/equatable.dart';

enum ApprovementStates { awaiting, approved, notApproved }

extension ApprovementStatesExtension on ApprovementStates {
  String get value {
    switch (this) {
      case ApprovementStates.awaiting:
        return "awaiting";
      case ApprovementStates.approved:
        return "approved";
      case ApprovementStates.notApproved:
        return "not_approved";
    }
  }
}

class Profile extends Equatable {
  late String id;
  late String userId;
  late String title;
  late String text;
  late String image;
  late bool isPattern;
  late String chatId;
  late String approvementState;

  Profile({required this.userId, required this.title, required this.text, required this.image, this.isPattern = false, this.chatId = "none", this.approvementState = "awaiting"});

  Profile.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    userId = data['userId'];
    title = data['title'];
    text = data['text'];
    image = data['image'];
    isPattern = data['isPattern'];
    chatId = data['chatId'];
    approvementState = data['isApproved'];
  }

  @override
  List<Object?> get props => [id, userId, title, text, image, isPattern, chatId, approvementState];

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "title": title,
      "text": text,
      "id": id,
      "image": image,
      "isPattern": isPattern,
      'chatId': chatId,
      'isApproved': approvementState
    };
  }
}