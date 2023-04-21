import 'package:flutter/material.dart';
import 'package:my_app/user_menu.dart';
import 'package:my_app/models/group.dart';

class Docs extends StatefulWidget {
  const Docs({super.key});

  @override
  State<Docs> createState() => _DocsState();
}

class _DocsState extends State<Docs> {
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
        child: Text('Documents Page'),
      ),
    );
  }
}
