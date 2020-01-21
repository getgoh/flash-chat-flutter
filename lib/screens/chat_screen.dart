import 'package:firebase_auth/firebase_auth.dart';
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
        loggedInUser = user;
        print(loggedInUser.email);
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

    return Scaffold(
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
          Navigator.popUntil(context, ModalRoute.withName(ChatListScreen.id));
          return null;
        },
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(
                groupId: groupId,
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
                        };
                        _firestore.collection('messages').add(currMsg);
                        // update group's lastTimeStamp and recentMessage
                        DocumentReference ref =
                            _firestore.collection('groups').document(groupId);
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
    );
  }
}

class MessagesStream extends StatelessWidget {
  final String groupId;

  const MessagesStream({@required this.groupId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages')
          .where('groupId', isEqualTo: this.groupId)
          .orderBy('time_stamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } else {
          print('SNAPSHOT HAS DATA!');
          print(snapshot.data.documents);
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messageBubbles = [];
          print(messages.length);
          for (var message in messages) {
            final messageText = message.data['content'];
            final messageSender = message.data['from_name'];
            final messageSenderId = message.data['from_id'];

            final currentUser = loggedInUser.uid;

            final messageBubble = MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: messageSenderId == currentUser,
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20.0,
              ),
              children: messageBubbles,
            ),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  const MessageBubble({this.sender, this.text, this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          isMe
              ? SizedBox()
              : Text(
                  sender,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.black54,
                  ),
                ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '$text',
                style: TextStyle(
                  fontSize: 15.0,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
