import 'package:flutter/material.dart';
import 'package:my_app/user_menu.dart';

class Chat extends StatefulWidget {
  Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // final String _groupName = UserMenu().getCurrentGroup();
  final String _groupName = "COMP 589";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserMenu(),
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
