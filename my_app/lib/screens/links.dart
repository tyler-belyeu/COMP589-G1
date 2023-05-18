import 'package:any_link_preview/any_link_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:my_app/main.dart';
import 'package:my_app/models/group.dart';
import 'package:my_app/models/link.dart';
import 'package:my_app/services/auth.dart';
import 'package:my_app/services/database.dart';
import 'package:my_app/user_menu.dart';

class Links extends StatefulWidget {
  const Links({super.key});

  @override
  State<Links> createState() => _LinksState();
}

class _LinksState extends State<Links> {
  final User? user = Auth().currentUser;
  String _groupName = Group.groupName;
  String _groupID = Group.groupID;

  List<Link> _links = [];
  final TextEditingController _controller = TextEditingController();

  Future<List<Link>> _getLinks(String groupID) async {
    if (groupID == "") return [];

    DatabaseService db = DatabaseService(uid: user!.uid);
    List<Link> links = await db.getGroupLinks(groupID);
    return links;
  }

  void _alertInvalidURL(String url) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text("Invalid URL: \n$url"),
      ),
    );
  }

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
        body: FutureBuilder(
          future: _getLinks(Group.groupID),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Column(children: [
                  const Expanded(
                    child: Center(child: Text("Send a link")),
                  ),
                  Container(
                    color: Colors.grey.shade300,
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        hintText: "New link",
                      ),
                      onSubmitted: (text) {
                        bool isURLValid = AnyLinkPreview.isValidLink(text);

                        if (isURLValid) {
                          DatabaseService db = DatabaseService(uid: user!.uid);
                          final link = Link(
                              url: text, date: DateTime.now(), uid: user!.uid);
                          db.createLink(
                              Group.groupID, link.url, link.date, link.uid);

                          setState(() {
                            _links.add(link);
                            _controller.text = "";
                          });
                        }
                        else {
                          _alertInvalidURL(text);
                        }
                      },
                    ),
                  )
                ]);
              } else {
                return Column(
                  children: [
                    Expanded(
                        child: GroupedListView<Link, DateTime>(
                          reverse: true,
                          order: GroupedListOrder.DESC,
                          useStickyGroupSeparators: true,
                          floatingHeader: true,
                          padding: const EdgeInsets.all(8),
                          elements: snapshot.data!,
                          groupBy: (link) => DateTime(
                            link.date.year,
                            link.date.month,
                            link.date.day,
                          ),
                        groupHeaderBuilder: (Link link) => Container(),
                        itemBuilder: (context, Link link) {
                          if (link.uid == user!.uid) link.sentByMe = true;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                elevation: 8,
                                  child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: (MediaQuery.of(context).size.width) * 0.8),
                                    child: AnyLinkPreview(
                                      link: link.url,
                                      borderRadius: 0,
                                      backgroundColor: Colors.white,
                                      removeElevation: true,
                                      bodyMaxLines: 5,
                                      previewHeight: (MediaQuery.of(context).size.width) * 0.7,
                                    ),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    ),
                    Container(
                      color: Colors.grey.shade300,
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          hintText: "New link",
                        ),
                        onSubmitted: (text) {
                          bool isURLValid = AnyLinkPreview.isValidLink(text);

                          if (isURLValid) {
                            DatabaseService db = DatabaseService(uid: user!.uid);
                            final link = Link(
                                url: text, date: DateTime.now(), uid: user!.uid);
                            db.createLink(
                                Group.groupID, link.url, link.date, link.uid);

                            setState(() {
                              _links.add(link);
                              _controller.text = "";
                            });
                          }
                          else {
                            _alertInvalidURL(text);
                          }
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
        ));
  }
}
