import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roleplaying_app/src/models/chat.dart';
import 'package:roleplaying_app/src/models/rolePlayQueue.dart';

class RolePlayQueueService {
  final Chat chat;
  late CollectionReference rolePlayQueueCollection;
  RolePlayQueueService(this.chat) {
    rolePlayQueueCollection = FirebaseFirestore.instance.collection("chats");
  }

  Future addQueue(RolePlayQueue rolePlayQueue) async {
    DocumentReference docRef = rolePlayQueueCollection.doc(chat.id).collection("rolePlayQueue").doc();
    return await docRef.set({
      "id": docRef.id,
      "users": rolePlayQueue.users
    });
  }

  Future updateQueue(RolePlayQueue rolePlayQueue) async {
    await rolePlayQueueCollection.doc(chat.id).collection("rolePlayQueue").doc(rolePlayQueue.id).update(rolePlayQueue.toMap());
  }

  Future deleteQueue(RolePlayQueue rolePlayQueue) async {
    await rolePlayQueueCollection.doc(chat.id).collection("rolePlayQueue").doc(rolePlayQueue.id).delete();
  }

  Future<RolePlayQueue> getQueue(String queueId) async {
    DocumentReference docRef =  rolePlayQueueCollection.doc(chat.id).collection("rolePlayQueue").doc(queueId);
    return await docRef.get().then((value) {
      RolePlayQueue queue = RolePlayQueue(
          users: value.get("users")
      );
      queue.id = value.get("id");
      return queue;
    });
  }

  Future<List<RolePlayQueue>> getQueueByUserId(String userId) async {
    List<RolePlayQueue> list = [];
    await rolePlayQueueCollection.doc(chat.id).collection("rolePlayQueue").where("users", arrayContains: userId).get().then((value) {
      for(int i = 0; i < value.docs.length; i++) {
        log(i.toString(), name: "COUNT");
        list.add(RolePlayQueue.fromJson(value.docs[i].data()));
      }
    });
    return list;
  }

  Future changePositions(String queueId, String prevUserId) async {
    try {
      RolePlayQueue queue = await getQueue(queueId);
      List list = List.of(queue.users);
      list.remove(prevUserId);
      list.add(prevUserId);
      queue.users = list;
      updateQueue(queue);
    } catch(e) {
      log(e.toString(), name: "CHANGING QUEUE ERROR");
    }
  }

  ///Getting list stream of queues
  Stream<List<RolePlayQueue>> readQueues() =>
      FirebaseFirestore.instance.collection("chats").doc(chat.id).collection("rolePlayQueue").snapshots().map(
              (snapshot) => snapshot.docs.map((doc) => RolePlayQueue.fromJson(doc.data())).toList());
}