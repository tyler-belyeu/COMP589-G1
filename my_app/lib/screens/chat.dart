import 'package:flutter/material.dart';
import 'package:my_app/user_menu.dart';

class Chat extends StatelessWidget {
  Chat({super.key});

  final String _groupName = UserMenu().getCurrentGroup();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserMenu(),
      appBar: AppBar(
        title: Text("COMP 589"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text('Chat Page'),
      ),
    );
  }
}
