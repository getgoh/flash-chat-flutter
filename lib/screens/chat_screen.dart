import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/chat_screen_messages_stream.dart';
import 'package:flash_chat/helpers/shared_prefs.dart';
import 'package:flash_chat/models/chat_arguments.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flash_chat/screens/chat_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
User currUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;

  ChatArguments args;
  String groupId;
  String chatName = '';

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      currUser = await SharedPrefs.getLoggedInUser();
      if (user != null) {
        setState(() {
          loggedInUser = user;
//          print(loggedInUser.email);
        });
      }
    } catch (ex) {
      print(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    groupId = args.groupId;
    chatName = args.chatName;

    return loggedInUser != null
        ? Scaffold(
            appBar: AppBar(
              leading: null,
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () async {
//                User currUser = await SharedPrefs.getLoggedInUser();
//                print(currUser.name);
//                print(currUser.id);
//                print(currUser.email);
//                print(currUser.imgUrl);
//                print(currUser.about);

//                _auth.signOut();
//                Navigator.pop(context);
                    }),
              ],
              title: Text(chatName),
              backgroundColor: Colors.lightBlueAccent,
            ),
            body: WillPopScope(
              onWillPop: () {
                Navigator.popUntil(
                    context, ModalRoute.withName(ChatListScreen.id));
                return null;
              },
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ChatScreenMessagesStream(
                      groupId: groupId,
                      loggedInUser: loggedInUser,
                    ),
                    Container(
                      decoration: kMessageContainerDecoration,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: messageTextController,
                              style: kTextFieldTextStyle,
                              onChanged: (value) {
                                messageText = value;
                              },
                              decoration: kMessageTextFieldDecoration,
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              messageTextController.clear();
                              var currTimeStamp = FieldValue.serverTimestamp();
                              Map<String, dynamic> currMsg = {
                                'content_type': 'text',
                                'content': messageText,
                                'from_id': loggedInUser.uid,
                                'to_id': '',
                                'time_stamp': currTimeStamp,
                                'groupId': groupId,
                                'from_name': currUser.name,
                                'from_imgUrl': currUser.imgUrl,
                              };
                              _firestore.collection('messages').add(currMsg);
                              // update group's lastTimeStamp and recentMessage
                              DocumentReference ref = _firestore
                                  .collection('groups')
                                  .document(groupId);
                              ref.updateData({
                                'lastTimeStamp': currTimeStamp,
                                'recentMessage': currMsg
                              });
                            },
                            child: Text(
                              'Send',
                              style: kSendButtonTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : SizedBox();
  }
}
