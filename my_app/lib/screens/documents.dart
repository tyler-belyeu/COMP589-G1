import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_app/services/auth.dart';
import 'package:my_app/services/database.dart';
import 'package:my_app/user_menu.dart';
import 'package:my_app/models/group.dart';
import 'package:my_app/services/storage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class Docs extends StatefulWidget {
  const Docs({super.key});

  @override
  State<Docs> createState() => _DocsState();
}

class _DocsState extends State<Docs> {
  final User? user = Auth().currentUser;

  String _groupName = Group.groupName;
  int _numDocuments = 0;

  bool _fileIsImage(String fileName) {
    List<String> split = fileName.split(".");
    if (split.last == "png") {
      return true;
    }

    return false;
  }

  Future<List<Widget>> _getDocuments(String groupId) async {
    List<String> fileNames = [];
    final storageRef = Storage().storageRef.child(Group.groupID);
    final listResult = await storageRef.listAll();
    for (var item in listResult.items) {
      fileNames.add(item.name);
    }
    print(fileNames);

    List<Widget> tiles = [];
    for (var fileName in fileNames) {
      IconData tileIcon = Icons.description;
      if (_fileIsImage(fileName)) {
        tileIcon = Icons.image;
      }
      // else if ...

      GridTile newTile = GridTile(
        // header: const GridTileBar(backgroundColor: Colors.red),
        // footer: const GridTileBar(backgroundColor: Colors.red),
        child: Center(
          child: SizedBox.fromSize(
            size: const Size(155, 155),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: Material(
                  color: Colors.black,
                  child: InkWell(
                      // splashColor: Colors.white,
                      onTap: () {
                        _openFile(fileName);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tileIcon,
                            size: 100,
                            color: Colors.white,
                          ),
                          Text(
                            fileName,
                            maxLines: 3,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 1,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )),
                )),
          ),
        ),
      );

      tiles.add(newTile);
    }

    GridTile uploadTile = GridTile(
      child: Center(
        child: SizedBox.fromSize(
          size: const Size(155, 155),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Material(
                color: Colors.white,
                child: InkWell(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result == null) return;

                      // else upload file
                      final file = result.files.first;
                      _uploadFile(file);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.upload_file,
                          size: 100,
                          color: Colors.black,
                        ),
                        Text(
                          "Upload Document",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 1,
                              color: Colors.black),
                        ),
                      ],
                    )),
              )),
        ),
      ),
    );
    tiles.add(uploadTile);

    return tiles;
  }

  void refreshTitle() {
    setState(() {
      if (_groupName != Group.groupName) {
        _groupName = Group.groupName;
      }
    });
  }

  void _uploadFile(PlatformFile file) async {
    final storagePath = "${Group.groupID}/${file.name}";
    final fileRef = Storage().storageRef.child(storagePath);
    final uploadFile = File(file.path!);

    try {
      await fileRef.putFile(uploadFile);
    } on FirebaseException catch (e) {
      // ...
    }
  }

  Future _openFile(String fileName) async {
    final storagePath = "${Group.groupID}/$fileName";
    final fileRef = Storage().storageRef.child(storagePath);
    final url = await fileRef.getDownloadURL();
    // print(url);

    final file = await _downloadFile(url, fileName);
    if (file == null) {
      print("null file returned");
      return;
    }

    print('Path: ${file.path}');
    print('Size: ${await file.length()}');
    OpenFile.open(file.path);
  }

  Future<File?> _downloadFile(String url, String fileName) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File("${appStorage.path}/$fileName");
    // print(file.path);

    try {
      final response = await Dio().get(url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: const Duration(seconds: 10),
          ));

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      return file;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // void _openFile(String fileName) async {
  //   // if (await Permission.manageExternalStorage.request().isGranted) {
  //   final storagePath = "${Group.groupID}/${fileName}";
  //   final fileRef = Storage().storageRef.child(storagePath);

  //   final appDocDir = await getApplicationDocumentsDirectory();
  //   final filePath = "${appDocDir.absolute.path}/$storagePath";
  //   final file = File(filePath);
  //   print(filePath);

  //   final downloadTask = fileRef.writeToFile(file);
  //   downloadTask.snapshotEvents.listen((taskSnapshot) {
  //     switch (taskSnapshot.state) {
  //       case TaskState.running:
  //         // TODO: Handle this case.
  //         print("downloading...");
  //         break;
  //       case TaskState.paused:
  //         // TODO: Handle this case.
  //         print("paused");
  //         break;
  //       case TaskState.success:
  //         // TODO: Handle this case.
  //         print("successfully downloaded");
  //         break;
  //       case TaskState.canceled:
  //         // TODO: Handle this case.
  //         print("canceled");
  //         break;
  //       case TaskState.error:
  //         // TODO: Handle this case.
  //         print("error");
  //         break;
  //     }
  //   });
  //   // }
  //   // OpenFile.open(file.path!);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserMenu(
        notifyScreen: refreshTitle,
      ),
      appBar: AppBar(
        title: Text(_groupName),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      // body: const Center(
      //   child: Text('Documents Page'),
      // body: GridView.count(
      //   crossAxisCount: 2,
      //   children: const [],
      // ),
      body: FutureBuilder(
        future: _getDocuments(_groupName),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.count(
              // crossAxisSpacing: 5,
              // mainAxisSpacing: 5,
              crossAxisCount: 2,
              children: snapshot.data!,
            );
          } else {
            return const Center(
              child: Text('Documents Page'),
            );
          }
        },
      ),
    );
  }
}
