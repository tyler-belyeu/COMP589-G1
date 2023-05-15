import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:my_app/models/group.dart';
import 'package:my_app/models/message.dart';
import 'package:my_app/services/auth.dart';
import 'package:my_app/services/database.dart';
import 'package:my_app/user_menu.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final User? user = Auth().currentUser;
  String _groupName = Group.groupName;

  List<Message> _messages = [];
  // [
  //   Message(text: "Example message", date: DateTime.now(), uid: ""),
  // ];
  final TextEditingController _controller = TextEditingController();

  Future<List<Message>> _getMessages(String groupID) async {
    DatabaseService db = DatabaseService(uid: user!.uid);
    List<Message> messages = await db.getGroupMessages(groupID);
    return messages;
  }

  String _userPhotoURL() {
    return user?.photoURL ??
        "https://upload.wikimedia.org/wikipedia/commons/c/cc/CSUN_Seal.png";
  }

  refreshTitle() {
    setState(() {
      _groupName = Group.groupName;
      // _messages = _getMessages(Group.groupID);
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
        body: FutureBuilder(
          future: _getMessages(Group.groupID),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Column(children: [
                  const Expanded(
                    child: Center(child: Text("Send a message")),
                  ),
                  Container(
                    color: Colors.grey.shade300,
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        hintText: "New message",
                      ),
                      onSubmitted: (text) {
                        DatabaseService db = DatabaseService(uid: user!.uid);
                        final message = Message(
                            text: text, date: DateTime.now(), uid: user!.uid);
                        db.createMessage(Group.groupID, message.text,
                            message.date, message.uid);

                        setState(() {
                          _messages.add(message);
                          _controller.text = "";
                        });
                      },
                    ),
                  )
                ]);
              } else {
                return Column(
                  children: [
                    Expanded(
                        child: GroupedListView<Message, DateTime>(
                      reverse: true,
                      order: GroupedListOrder.DESC,
                      useStickyGroupSeparators: true,
                      floatingHeader: true,
                      padding: const EdgeInsets.all(8),
                      elements: snapshot.data!,
                      groupBy: (message) => DateTime(
                        message.date.year,
                        message.date.month,
                        message.date.day,
                      ),
                      groupHeaderBuilder: (Message message) => SizedBox(
                        height: 40,
                        child: Align(
                          alignment: Alignment.center,
                          child: Card(
                            color: Colors.black,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                DateFormat.yMMMd().format(message.date),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      itemBuilder: (context, Message message) {
                        if (message.uid == user!.uid) message.sentByMe = true;

                        if (message.sentByMe) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Card(
                                elevation: 8,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 150),
                                      child: Text(message.text)),
                                ),
                              ),
                              ClipOval(
                                child: Image.network(
                                  _userPhotoURL(),
                                  width: 35,
                                  height: 35,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipOval(
                                child: Container(
                                  color: Colors.grey.shade600,
                                  width: 35,
                                  height: 35,
                                  child: const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Card(
                                elevation: 8,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 150),
                                      child: Text(message.text)),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    )),
                    Container(
                      color: Colors.grey.shade300,
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          hintText: "New message",
                        ),
                        onSubmitted: (text) {
                          DatabaseService db = DatabaseService(uid: user!.uid);
                          final message = Message(
                              text: text, date: DateTime.now(), uid: user!.uid);
                          db.createMessage(Group.groupID, message.text,
                              message.date, message.uid);

                          setState(() {
                            _messages.add(message);
                            _controller.text = "";
                          });
                        },
                      ),
                    )
                  ],
                );
              }
            } else {
              return Container();
            }
          },
        )
        // const Center(
        //   child: Text('Chat Page'),
        // ),
        );
  }
}

// return Row(
//                   mainAxisAlignment: message.sentByMe
//                       ? MainAxisAlignment.end
//                       : MainAxisAlignment.start,
//                   children: [
//                     ClipOval(
//                       child: Image.network(
//                         _userPhotoURL(),
//                         width: 35,
//                         height: 35,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     Card(
//                       elevation: 8,
//                       child: Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: ConstrainedBox(
//                             constraints: const BoxConstraints(maxWidth: 150),
//                             child: Text(message.text)),
//                       ),
//                     ),
//                   ],
//                 );