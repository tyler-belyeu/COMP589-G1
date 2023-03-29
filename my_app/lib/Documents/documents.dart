import 'package:flutter/material.dart';
import 'package:my_app/user_menu.dart';

class Docs extends StatelessWidget {
  const Docs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: UserMenu(),
      appBar: AppBar(
        title: const Text("Group Name"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text('Documents Page'),
      ),
    );
  }
}
