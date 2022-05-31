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

  ///Getting list stream of queues
  Stream<List<RolePlayQueue>> readQueues() =>
      FirebaseFirestore.instance.collection("chats").doc(chat.id).collection("rolePlayQueue").snapshots().map(
              (snapshot) => snapshot.docs.map((doc) => RolePlayQueue.fromJson(doc.data())).toList());
}