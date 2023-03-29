import 'package:flutter/material.dart';
import 'package:my_app/user_menu.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  final String _groupName = "Group A";

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
