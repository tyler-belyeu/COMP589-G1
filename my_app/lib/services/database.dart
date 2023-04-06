import 'package:cloud_firestore/cloud_firestore.dart';

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
        final data = doc.data() as Map<String, dynamic>;
        return data[key];
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  Future<dynamic> getGroupsData(String groupID, String key) async {
    return groupCollection.doc(groupID).get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data[key];
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
