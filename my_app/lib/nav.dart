import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:my_app/screens/chat.dart';
import 'package:my_app/screens/documents.dart';
import 'package:my_app/screens/links.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    Chat(),
    const Docs(),
    const Links()
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.chat,
                text: "Chat",
              ),
              GButton(
                icon: Icons.assignment,
                text: "Docs",
              ),
              GButton(
                icon: Icons.link,
                text: "Links",
              )
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTap,
          ),
        ),
      ),
    );
  }
}