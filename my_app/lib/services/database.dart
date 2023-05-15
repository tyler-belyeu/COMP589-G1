import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/message.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  // collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // Update user's array of group id's in firestore
  Future updateUserData(var groups) async {
    return await userCollection.doc(uid).set({
      'groups': groups,
    });
  }

  Future<dynamic> getUserData(String key) async {
    return userCollection.doc(uid).get().then(
      (DocumentSnapshot doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return data[key];
        } else {
          return [];
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  Future createMessage(
      String groupID, String text, DateTime date, String uid) async {
    DocumentReference doc = await groupCollection
        .doc(groupID)
        .collection("messages")
        .add({'text': text, 'userID': uid, 'timestamp': date});
  }

  Future<dynamic> getGroupMessages(String groupID) async {
    if (groupID == "") groupID = "COMP 589";
    final CollectionReference messageCollection =
        FirebaseFirestore.instance.collection("groups/$groupID/messages");

    // Get docs from collection reference
    QuerySnapshot querySnapshot = await messageCollection.get();

    // Get data from docs and convert map to List
    final messages = querySnapshot.docs.map((doc) => doc.data()).toList();

    // print(messages);
    List<Message> list = [];
    for (var message in messages) {
      var msg = message as Map<String, dynamic>;
      var text = msg["text"];
      Timestamp timestamp = msg["timestamp"];
      var date = timestamp.toDate();
      var uid = msg["userID"];
      var newMessage = Message(text: text, date: date, uid: uid);
      list.add(newMessage);
    }

    list.sort((a, b) {
      var adate = a.date;
      var bdate = b.date;
      return adate.compareTo(bdate);
    });

    for (var message in list) {
      print("${message.text}, sent at ${message.date} by ${message.uid}");
    }

    return list;
  }

  Future<dynamic> getGroupsData(String groupID, String key) async {
    return groupCollection.doc(groupID).get().then(
      (DocumentSnapshot doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return data[key];
        } else {
          return [];
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  Future<String> createGroup(String creator, String name, var usersList) async {
    DocumentReference doc = await groupCollection.add({
      'created_by': creator,
      'name': name,
      'users': usersList,
    });
    return doc.id;
  }
}
