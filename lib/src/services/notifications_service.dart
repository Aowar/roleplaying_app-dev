import 'dart:developer';
import 'dart:io' show File, Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/models/notifications/notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

class NotificationsService {
  final String userId;
  late CollectionReference notificationsCollection;
  NotificationsService(this.userId) {
    notificationsCollection = FirebaseFirestore.instance.collection("users").doc(userId).collection("notifications");
  }

  Future addNotification(Notifications notification) async {
    DocumentReference docRef = notificationsCollection.doc();
    await docRef.set({
      'id': docRef.id,
      'title': notification.title,
      'text': notification.text,
      'creationTime': notification.creationTime,
      'type': notification.type,
      'navigationId': notification.navigationId,
      'isRead': notification.isRead
    });
  }

  successApprovementNotification(String chatTitle, String navigationId) {
    addNotification(
        Notifications(
            title: "Ваша анкета одобрена",
            text: "Огранизатор одобрил вашу анкету для чата \"" + chatTitle + "\"",
            creationTime: Timestamp.now(),
            type: NotificationType.profile.value,
            navigationId: navigationId
        )
    );
  }

  failureApprovementNotification(String chatTitle, String navigationId) {
    addNotification(
        Notifications(
            title: "Ваша анкета отклонена",
            text: "Огранизатор одобрил вашу анкету для чата \"" + chatTitle + "\"",
            creationTime: Timestamp.now(),
            type: NotificationType.profile.value,
            navigationId: navigationId
        )
    );
  }

  Future setNotificationToRead(String notificationId) async {
    await notificationsCollection.doc(notificationId).update({
      'isRead': true
    });
  }

  Future deleteNotification(String notificationId) async {
    DocumentReference docRef = notificationsCollection.doc(notificationId);
    return await docRef.delete();
  }

  deleteAllNotifications() async {
    await notificationsCollection.get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  deleteNotificationsByNavId(List navIds) async {
    final query = notificationsCollection.where("id", whereIn: navIds);
    return await query.get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  ///Getting list stream of notifications
  Stream<List<Notifications>> readNotifications() {
    return FirebaseFirestore.instance.collection("users").doc(userId).collection("notifications").snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => Notifications.fromJson(doc.data())).toList()).asBroadcastStream();
  }

  Stream<bool> notificationsExists() {
    return FirebaseFirestore.instance.collection("users").doc(userId).collection("notifications").snapshots().any((element) => element.docs.isNotEmpty).asStream();
  }
}

class LocalNotificationService {
  var initializationSettings;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final BehaviorSubject<Notifications> didReceivedLocalNotificationSubject = BehaviorSubject<Notifications>();

  LocalNotificationService._() {
    init();
  }

  void init() async{
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializePlatformSpecifics();
  }

  initializePlatformSpecifics() {
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid
    );
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: (String? payload) async {
          onNotificationClick(payload);
        }
    );
  }
  Future<void> showNotification(Notifications receivedNotification, String userId) async {
    var androidChannelSpecifics = const AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        channelDescription: "CHANNEL_DESCRIPTION",
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        timeoutAfter: 5000,
    );

    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics
    );
    String payload = receivedNotification.type + "\n" + receivedNotification.navigationId;
    await flutterLocalNotificationsPlugin.show(
        0,
        receivedNotification.title,
        receivedNotification.text,
        platformChannelSpecifics,
        payload: payload
    );
    NotificationsService(userId).setNotificationToRead(receivedNotification.id);
  }
}

LocalNotificationService localNotificationService = LocalNotificationService._();