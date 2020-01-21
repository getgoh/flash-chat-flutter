import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final String imgUrl;

  const MessageBubble({this.sender, this.text, this.isMe, this.imgUrl});

  @override
  Widget build(BuildContext context) {
    print('ImgUrl: $imgUrl');
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          isMe
              ? SizedBox()
              : CircleAvatar(
                  backgroundImage: NetworkImage(imgUrl),
                ),
          SizedBox(
            width: 10.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
        ],
      ),
    );
  }
}
