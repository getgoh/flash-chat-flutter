import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/message_bubble.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';

final _firestore = Firestore.instance;

class ChatScreenMessagesStream extends StatelessWidget {
  final String groupId;
  final FirebaseUser loggedInUser;

  const ChatScreenMessagesStream({@required this.groupId, this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    String currentUser = loggedInUser.uid;

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
            final bool isMe = messageSenderId == currentUser;
            final messageImgUrl = isMe ? '' : message.data['from_imgUrl'];

            print(isMe);
            print(messageText);

            final messageBubble = MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: isMe,
              imgUrl: messageImgUrl,
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
