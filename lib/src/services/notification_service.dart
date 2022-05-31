import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // createNotification(String title, String description) async {
  //   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //   FlutterLocalNotificationsPlugin();
  //   AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     'high_importance_channel', // id
  //     title, // title
  //     description: description,
  //     importance: Importance.high,
  //   );
  //   await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  //       ?.createNotificationChannel(channel);
  // }
  //
  // Future<void> setupInteractedMessage() async {
  //   // Get any messages which caused the application to open from
  //   // a terminated state.
  //   RemoteMessage? initialMessage =
  //   await FirebaseMessaging.instance.getInitialMessage();
  //
  //   // If the message also contains a data property with a "type" of "chat",
  //   // navigate to a chat screen
  //   if (initialMessage != null) {
  //     _handleMessage(initialMessage);
  //   }
  //   FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  // }

  // void _handleMessage(RemoteMessage message) {
  //   if (message.data['type'] == 'chat') {
  //     Navigator.pushNamed(context, '/chat',
  //       arguments: ChatArguments(message),
  //     );
  //   }
  // }
}