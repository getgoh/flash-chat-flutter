import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/helpers/shared_prefs.dart';
import 'package:flash_chat/models/chat_arguments.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  static String id = 'chat_list_screen';

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

final _firestore = Firestore.instance;
final _auth = FirebaseAuth.instance;
User loggedInUser;
final DateFormat format = DateFormat('jm');

List<String> loggedInUserGroups;

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();

    getUserGroups();
  }

  void getUserGroups() async {
    loggedInUser = await SharedPrefs.getLoggedInUser();
    setState(() {});

//    print('User: ${loggedInUser.groups}');

    try {
      final user = await _auth.currentUser();
      if (user != null) {
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('id', isEqualTo: user.uid)
            .getDocuments();

        DocumentSnapshot fsUser = result.documents[0];

        setState(() {
          loggedInUserGroups = List.castFrom(fsUser['groups']);
        });
      }
    } catch (ex) {
      print(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ChatListMessagesStream(),
      ),
    );
  }
}

class ChatListMessagesStream extends StatelessWidget {
  getUser() async {
    if (loggedInUser == null) {
      loggedInUser = await SharedPrefs.getLoggedInUser();
    }
  }

  test() async {
    if (loggedInUser == null) {
      loggedInUser = await SharedPrefs.getLoggedInUser();
    }

    QuerySnapshot groups = await _firestore
        .collection('groups')
        .where('members', arrayContains: loggedInUser.id)
        .orderBy('lastTimeStamp')
        .getDocuments();
    List<DocumentSnapshot> results = [];

    print('numGroups: ${groups.documents.length}');

    for (DocumentSnapshot group in groups.documents) {
      print(group['_id']);
//      List<dynamic> members = group['members'];
//      if (members.contains(loggedInUser.uid)) {
//        results.add(group);
//      }
    }
//    print('Members: ${results[0]['_id']}');
  }

  @override
  Widget build(BuildContext context) {
    _buildStream() {
//      getUser();

      Stream<QuerySnapshot> stream = loggedInUser != null
          ? _firestore
              .collection('groups')
              .where('members', arrayContains: loggedInUser.id)
              .orderBy('lastTimeStamp')
              .snapshots()
          : _firestore
              .collection('groups')
              .orderBy('lastTimeStamp')
              .snapshots();

      return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          } else {
            final groups = snapshot.data.documents.reversed;
            List<GestureDetector> groupsList = [];
            for (var group in groups) {
              String groupId = group['_id'];
              String chatName = group['chatName'];
              String fromName =
                  loggedInUser.id == group.data['recentMessage']['from_id']
                      ? 'Me'
                      : group.data['recentMessage']['from_name'];

              int timeStampSeconds =
                  group.data['recentMessage']['time_stamp'].seconds;
              String lastMsgContent =
                  group.data['recentMessage']['content_type'] == 'image'
                      ? 'Image'
                      : group.data['recentMessage']['content'];
//
              DateTime dt =
                  Timestamp.fromMillisecondsSinceEpoch(timeStampSeconds * 1000)
                      .toDate();
//              print(dt.);

              final messageBubble = GestureDetector(
                onTap: () {
                  // open chat screen with this groupId
                  print('TAPPED');
                  Navigator.pushNamed(
                    context,
                    ChatScreen.id,
                    arguments:
                        ChatArguments(groupId: groupId, chatName: chatName),
                  );
                },
                child: Card(
                  margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              chatName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${format.format(dt)}'),
//                            Text('-'),
                          ],
                        ),
                        Text('$fromName: $lastMsgContent')
                      ],
                    ),
                  ),
                ),
              );
              groupsList.add(messageBubble);
            }
            return Scaffold(
              appBar: AppBar(
                title: Text('⚡️Chat'),
                backgroundColor: Colors.lightBlueAccent,
                actions: <Widget>[
                  IconButton(
                    onPressed: () {
                      // show users list screen
                      Navigator.pushNamed(context, UserListScreen.id);
                    },
                    icon: Icon(
                      Icons.open_in_new,
                      color: Colors.white70,
                    ),
                  )
                ],
              ),
              body: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 20.0,
                ),
                children: groupsList,
              ),
            );
          }
        },
      );
    }

    return _buildStream();
  }
}
