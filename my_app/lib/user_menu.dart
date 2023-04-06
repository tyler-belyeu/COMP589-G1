import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/main.dart';
import 'package:my_app/services/auth.dart';
import 'package:my_app/services/database.dart';

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

  final String _currentGroup = 'Group';
  String _newGroupName = '';
  final TextEditingController _alertDialogController = TextEditingController();

  String getCurrentGroup() {
    return _currentGroup;
  }

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

  void _alertGetNewGroupName() {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text("Enter Group Name:"),
        content: TextField(
          onChanged: (value) {},
          controller: _alertDialogController,
          decoration: const InputDecoration(hintText: "Group Name"),
        ),
        actions: [
          MaterialButton(
            color: Colors.red,
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context);
              _alertDialogController.text = '';
            },
            child: const Text('Cancel'),
          ),
          MaterialButton(
            color: Colors.black,
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context);
              _createNewGroup();
              _alertDialogController.text = '';
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewGroup() async {
    DatabaseService db = DatabaseService(uid: user!.uid);
    var usersList = [user!.uid];
    String groupID =
        await db.createGroup(user!.uid, _alertDialogController.text, usersList);
    List groups = await db.getUserData("groups");
    // now append groupID to user's groupsList and updateUserData()
    print(groups);
    groups.add(groupID);
    db.updateUserData(groups);
  }

  Future<List<Widget>> _getGroupTiles() async {
    DatabaseService db = DatabaseService(uid: user!.uid);
    List groups = await db.getUserData("groups");

    List<ListTile> groupTiles = [];
    for (int i = 0; i < groups.length; i++) {
      ListTile tile = ListTile(
          title: Text(
        await db.getGroupsData(groups[i], 'name'),
        style: const TextStyle(fontSize: 24.0),
      ));
      groupTiles.add(tile);
    }

    ListTile createNewGroupTile = ListTile(
      leading: const Icon(
        Icons.add,
      ),
      title: const Text(
        "Create New",
        style: TextStyle(fontSize: 24.0),
      ),
      onTap: _alertGetNewGroupName,
    );
    groupTiles.add(createNewGroupTile);

    return groupTiles;
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
              child: FutureBuilder(
                future: _getGroupTiles(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: snapshot.data!,
                    );
                  } else {
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: const [],
                    );
                  }
                },
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
  }
}
