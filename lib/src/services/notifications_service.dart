import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/models/notifications/notifications.dart';

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
      'navigationId': notification.navigationId
    });
  }

  Future deleteNotification(String notificationId) async {
    DocumentReference docRef = notificationsCollection.doc(notificationId);
    return await docRef.delete();
  }

  ///Getting list stream of notifications
  Stream<List<Notifications>> readNotifications() {
    return FirebaseFirestore.instance.collection("users").doc(userId).collection("notifications").snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => Notifications.fromJson(doc.data())).toList());
  }

  Stream<bool> notificationsExists() {
    return FirebaseFirestore.instance.collection("users").doc(userId).collection("notifications").snapshots().any((element) => element.docs.isNotEmpty).asStream();
  }
}