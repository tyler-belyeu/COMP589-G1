import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  final storage = FirebaseStorage.instance;
  final storageRef = FirebaseStorage.instance.ref();
}
