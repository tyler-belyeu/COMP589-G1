import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/auth.dart';

// Disables over-scroll glow effect that normally happens
// when you try to scroll past the end of a list view
class NoGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class UserMenu extends StatelessWidget {
  UserMenu({super.key});

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      return await Auth().signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      print(e);
      return null;
    }
  }

  Widget _userEmail() {
    return Text(user?.email ?? 'User email');
  }

  Widget _userName() {
    return Text(user?.displayName ?? 'User name');
  }

  String _userPhotoURL() {
    return user?.photoURL ??
        "https://upload.wikimedia.org/wikipedia/commons/c/cc/CSUN_Seal.png";
  }

  ListTile _logInTile() {
    return ListTile(
        leading: Image.network(
          "https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-1024.png",
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
        title: const Text("Sign in with Google"),
        onTap: () {
          Auth().signInWithGoogle();
        });
  }

  ListTile _logOutTile() {
    return ListTile(
        leading: const Icon(Icons.exit_to_app),
        title: const Text("Sign Out"),
        onTap: () {
          signOut();
        });
  }

  Drawer _loggedInDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: _userName(),
            accountEmail: _userEmail(),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  _userPhotoURL(),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: const BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: NetworkImage(
                      "https://thestreamable.com/media/pages/sports/ncaa-mens-basketball/cal-state-northridge-matadors/4818166150-1576040064/cal-state-northridge-matadors-banner.png"),
                  fit: BoxFit.cover,
                )),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: NoGlow(),
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  ListTile(
                    title: Text(
                      "Group A",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    textColor: Colors.blue,
                  ),
                  ListTile(
                    title: Text(
                      "Group B",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    textColor: Colors.red,
                  ),
                  ListTile(
                    title: Text(
                      "Group C",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    textColor: Colors.green,
                  ),
                  ListTile(
                    title: Text(
                      "Group D",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    textColor: Colors.black,
                  ),
                  ListTile(
                    title: Text(
                      "Group E",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    textColor: Colors.yellow,
                  ),
                  ListTile(
                    title: Text(
                      "Group F",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    textColor: Colors.purple,
                  ),
                  ListTile(
                    title: Text(
                      "Group G",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    textColor: Colors.teal,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.add,
                      color: Colors.orange,
                    ),
                    title: Text(
                      "Create New",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    textColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: null,
          ),
          StreamBuilder<User?>(
            stream: Auth().authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _logOutTile();
              } else {
                return _logInTile();
              }
            },
          ),
          // Auth().authStateChanges != null ? _logOutTile() : _logInTile(),
          // user != null ? _logOutTile() : _logInTile(),
        ],
      ),
    );
  }

  Drawer _loggedOutDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text(""),
            accountEmail: const Text(""),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/c/cc/CSUN_Seal.png",
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: const BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: NetworkImage(
                      "https://thestreamable.com/media/pages/sports/ncaa-mens-basketball/cal-state-northridge-matadors/4818166150-1576040064/cal-state-northridge-matadors-banner.png"),
                  fit: BoxFit.cover,
                )),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: NoGlow(),
              child: ListView(children: const [
                Center(child: Text("Sign In to View Your Groups")),
              ]),
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: null,
          ),
          StreamBuilder<User?>(
            stream: Auth().authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _logOutTile();
              } else {
                return _logInTile();
              }
            },
          ),
          // Auth().authStateChanges != null ? _logOutTile() : _logInTile(),
          // user != null ? _logOutTile() : _logInTile(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: StreamBuilder<User?>(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _loggedInDrawer();
          } else {
            return _loggedOutDrawer();
          }
        },
      ),
    );
    // return Drawer(
    //   child: Column(
    //     children: [
    //       UserAccountsDrawerHeader(
    //         accountName: _userName(),
    //         accountEmail: _userEmail(),
    //         currentAccountPicture: CircleAvatar(
    //           child: ClipOval(
    //             child: Image.network(
    //               "https://upload.wikimedia.org/wikipedia/commons/c/cc/CSUN_Seal.png",
    //               width: 90,
    //               height: 90,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //         ),
    //         decoration: const BoxDecoration(
    //             color: Colors.blue,
    //             image: DecorationImage(
    //               image: NetworkImage(
    //                   "https://thestreamable.com/media/pages/sports/ncaa-mens-basketball/cal-state-northridge-matadors/4818166150-1576040064/cal-state-northridge-matadors-banner.png"),
    //               fit: BoxFit.cover,
    //             )),
    //       ),
    //       Expanded(
    //         child: ScrollConfiguration(
    //           behavior: NoGlow(),
    //           child: ListView(
    //             padding: EdgeInsets.zero,
    //             children: const [
    //               ListTile(
    //                 title: Text(
    //                   "Group A",
    //                   style: TextStyle(fontSize: 24.0),
    //                 ),
    //                 textColor: Colors.blue,
    //               ),
    //               ListTile(
    //                 title: Text(
    //                   "Group B",
    //                   style: TextStyle(fontSize: 24.0),
    //                 ),
    //                 textColor: Colors.red,
    //               ),
    //               ListTile(
    //                 title: Text(
    //                   "Group C",
    //                   style: TextStyle(fontSize: 24.0),
    //                 ),
    //                 textColor: Colors.green,
    //               ),
    //               ListTile(
    //                 title: Text(
    //                   "Group D",
    //                   style: TextStyle(fontSize: 24.0),
    //                 ),
    //                 textColor: Colors.black,
    //               ),
    //               ListTile(
    //                 title: Text(
    //                   "Group E",
    //                   style: TextStyle(fontSize: 24.0),
    //                 ),
    //                 textColor: Colors.yellow,
    //               ),
    //               ListTile(
    //                 title: Text(
    //                   "Group F",
    //                   style: TextStyle(fontSize: 24.0),
    //                 ),
    //                 textColor: Colors.purple,
    //               ),
    //               ListTile(
    //                 title: Text(
    //                   "Group G",
    //                   style: TextStyle(fontSize: 24.0),
    //                 ),
    //                 textColor: Colors.teal,
    //               ),
    //               ListTile(
    //                 leading: Icon(
    //                   Icons.add,
    //                   color: Colors.orange,
    //                 ),
    //                 title: Text(
    //                   "Create New",
    //                   style: TextStyle(fontSize: 24.0),
    //                 ),
    //                 textColor: Colors.orange,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //       const Divider(),
    //       const ListTile(
    //         leading: Icon(Icons.settings),
    //         title: Text("Settings"),
    //         onTap: null,
    //       ),
    //       StreamBuilder<User?>(
    //         stream: Auth().authStateChanges,
    //         builder: (context, snapshot) {
    //           if (snapshot.hasData) {
    //             return _logOutTile();
    //           } else {
    //             return _logInTile();
    //           }
    //         },
    //       ),
    //       // Auth().authStateChanges != null ? _logOutTile() : _logInTile(),
    //       // user != null ? _logOutTile() : _logInTile(),
    //     ],
    //   ),
    // );
  }
}
