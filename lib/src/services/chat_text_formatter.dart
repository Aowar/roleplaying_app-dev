import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/models/notifications/notifications.dart';
import 'package:roleplaying_app/src/services/notifications_service.dart';

class ChatTextFormatter {
  final nextPlayerWord = RegExp(r' !next\z', caseSensitive: false);
  final String text;
  final String nextPlayerId;
  final String chatId;
  final String chatName;

  ChatTextFormatter({required this.nextPlayerId, required this.chatId, required this.chatName, required this.text});

  nextPlayerNotifier() {
    Notifications notification = Notifications(
        title: "Ваша очередь",
        text: "Ваш пост ждут в чате \"" + chatName + "\"",
        creationTime: Timestamp.now(),
        type: NotificationType.chat.value,
        navigationId: chatId
    );
    NotificationsService(nextPlayerId).addNotification(notification);
  }
}