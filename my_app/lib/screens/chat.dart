import 'package:flutter/material.dart';
import 'package:my_app/models/group.dart';
import 'package:my_app/user_menu.dart';

class Chat extends StatefulWidget {
  Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String _groupName = Group.groupName;

  refreshTitle() {
    setState(() {
      _groupName = Group.groupName;
    });
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
      ),
      body: const Center(
        child: Text('Chat Page'),
      ),
    );
  }
}
