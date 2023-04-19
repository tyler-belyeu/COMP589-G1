import 'package:flutter/material.dart';
import 'package:my_app/user_menu.dart';

class Links extends StatefulWidget {
  const Links({super.key});

  @override
  State<Links> createState() => _LinksState();
}

class _LinksState extends State<Links> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserMenu(),
      appBar: AppBar(
        title: const Text("COMP 589"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text('Links Page'),
      ),
    );
  }
}
