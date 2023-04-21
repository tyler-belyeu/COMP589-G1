import 'package:flutter/material.dart';
import 'package:my_app/models/group.dart';
import 'package:my_app/user_menu.dart';

class Links extends StatefulWidget {
  const Links({super.key});

  @override
  State<Links> createState() => _LinksState();
}

class _LinksState extends State<Links> {
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
        child: Text('Links Page'),
      ),
    );
  }
}
