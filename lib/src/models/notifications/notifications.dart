import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { chat, profile }

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.chat:
        return "chat_notification";
      case NotificationType.profile:
        return "profile_notification";
    }
  }
}

class Notifications {
  final String id;
  final String title;
  final String text;
  final Timestamp creationTime;
  final String type;
  final String navigationId;


  Notifications({this.id = "", required this.title, required this.text, required this.creationTime, required this.type, required this.navigationId});

  static Notifications fromJson(Map<String, dynamic> data) {
    return Notifications(
        id: data['id'],
        title: data['title'],
        text: data['text'],
        creationTime: data['creationTime'],
        type: data['type'],
        navigationId: data['navigationId']
    );
  }

  Map<String, dynamic> toMap(String id){
    return {
      'id': id,
      'title': title,
      'text': text,
      'creationTime': creationTime,
      'type': type,
      'navigationId': navigationId
    };
  }
}