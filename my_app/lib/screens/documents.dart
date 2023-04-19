import 'package:flutter/material.dart';
import 'package:my_app/user_menu.dart';

class Docs extends StatefulWidget {
  const Docs({super.key});

  @override
  State<Docs> createState() => _DocsState();
}

class _DocsState extends State<Docs> {
  String _groupName = "COMP 589";
  // should be:
  // String _groupName = UserMenu().getCurrentGroup();

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
        child: Text('Documents Page'),
      ),
    );
  }
}
