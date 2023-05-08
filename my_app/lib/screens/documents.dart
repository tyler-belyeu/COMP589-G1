import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/services/auth.dart';
import 'package:my_app/user_menu.dart';
import 'package:my_app/models/group.dart';
import 'package:my_app/services/storage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:my_app/main.dart';

class Docs extends StatefulWidget {
  const Docs({super.key});

  @override
  State<Docs> createState() => _DocsState();
}

class _DocsState extends State<Docs> {
  final User? user = Auth().currentUser;
  final TextEditingController _alertDialogController = TextEditingController();

  String _groupName = Group.groupName;
  int _numDocuments = 0;
  var _openResult = 'Unknown';
  bool _deleteMode = false;
  IconData _deleteButtonIcon = Icons.remove;

  // Set color for supported extensions based on their type,
  // or set grey for unsupported file types
  Color _getColor(String extension) {
    switch (extension) {
      // Documents
      case '.pdf':
      case '.doc':
      case '.docx':
        return Colors.red.shade400;

      // Text/Code
      case '.txt':
      case '.c':
      case '.cpp':
      case '.h':
      case '.htm':
      case '.html':
      case '.java':
      case '.sh':
      case '.xml':
        return Colors.lightGreen;

      // Images
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.bmp':
      case '.gif':
        return Colors.indigo;

      // Video
      case '.mp4':
      case '.m4v':
      case '.m4u':
      case '.mpe':
      case '.mpeg':
      case '.mpg':
      case '.mpg4':
      case '.3gp':
      case '.asf':
      case '.avi':
        return Colors.teal;

      // Audio
      case '.mp3':
      case '.mp2':
      case '.wav':
      case '.mpga':
      case '.rmvb':
      case '.wma':
      case '.wmv':
      case '.m3u':
      case '.m4a':
      case '.m4b':
      case '.m4p':
        return Colors.yellow.shade300;

      // Other/Un-openable
      default:
        return Colors.grey;
    }
  }

  Future<List<Widget>> _getDocuments(String groupId) async {
    List<String> fileNames = [];
    final storageRef = Storage().storageRef.child(Group.groupID);
    final listResult = await storageRef.listAll();
    for (var item in listResult.items) {
      fileNames.add(item.name);
    }

    List<Widget> tiles = [];
    for (var fileName in fileNames) {
      List<String> split = fileName.split(".");
      String extension = split.last;

      if (split.length == 1) {
        extension = "file";
      } else {
        extension = ".$extension";
      }

      final color = _getColor(extension);

      InkWell newTile = InkWell(
        onTap: () {
          if (_deleteMode) {
            _alertConfirmDelete(fileName, Group.groupName);
          } else {
            _openFile(fileName);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    extension,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fileName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                "",
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      );

      tiles.add(newTile);
    }

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
      print(e);
    }

    setState(() {
      _numDocuments++;
    });
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
    if (await Permission.manageExternalStorage.request().isGranted) {
      final result = await OpenFile.open(file.path);
      setState(() {
        _openResult = "type=${result.type}  message=${result.message}";
      });
    }
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

  void _alertConfirmDelete(String fileName, String groupName) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Delete $fileName from Group $groupName?"),
        actions: [
          MaterialButton(
            color: Colors.black,
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context);
              _alertDialogController.text = '';

              setState(() {
                _deleteMode = false;
              });
            },
            child: const Text('Cancel'),
          ),
          MaterialButton(
            color: Colors.red,
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(fileName);
              _alertDialogController.text = '';
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteFile(String fileName) async {
    final storagePath = "${Group.groupID}/${fileName}";
    final fileRef = Storage().storageRef.child(storagePath);

    try {
      await fileRef.delete();
    } on FirebaseException catch (e) {
      print(e);
    }

    // setState(() {
    //   _deleteMode = false;
    // });
  }

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
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _deleteMode = !_deleteMode;
                if (_deleteMode) {
                  _deleteButtonIcon = Icons.remove_circle;
                } else {
                  _deleteButtonIcon = Icons.remove;
                }
              });
            },
            icon: Icon(_deleteButtonIcon),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
          IconButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result == null) return;

              // else upload file
              final file = result.files.first;
              _uploadFile(file);
            },
            icon: const Icon(Icons.add),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _getDocuments(_groupName),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Upload A Document'),
              );
            } else {
              return GridView.count(
                crossAxisCount: 2,
                children: snapshot.data!,
              );
            }
          } else {
            return const Center(
              child: Text('Upload A Document'),
            );
          }
        },
      ),
    );
  }
}
