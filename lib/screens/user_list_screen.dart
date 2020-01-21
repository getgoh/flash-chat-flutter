import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/models/chat_arguments.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  static String id = 'user_list_screen';

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;
final List<bool> checkList = [];

CollectionReference usersRef;

List<DocumentSnapshot> users;
List<DocumentSnapshot> selectedUsers = [];

class _UserListScreenState extends State<UserListScreen> {
  final _auth = FirebaseAuth.instance;
  String chatName;
//  List<Card> userCardList = [];

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    getUsers();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print('Logged in user: ${loggedInUser.email}');
      }
    } catch (ex) {
      print('getCurrentUser error: $ex');
    }
  }

  getUsers() async {
    try {
      // get users list from firebase
      usersRef = _fireStore.collection('users');
      QuerySnapshot usersx = await usersRef.getDocuments();

      setState(() {
        users = usersx.documents;
        DocumentSnapshot currUser;
        for (var user in users) {
          print(user.data['email']);
          if (user.data['email'] != loggedInUser.email) {
            // populate checklist
            checkList.add(false);
          } else {
            currUser = user;
          }
        }
        // remove current used from users
        users.remove(currUser);
      });
    } catch (ex) {
      print('getUsers error: $ex');
    }
  }

//  buildUserCheckList() async {
//    QuerySnapshot usersx = await usersRef.getDocuments();
//    setState(() {
//      users = usersx.documents;
//
//      DocumentSnapshot currUser;
//      for (var user in users) {
//        print(user.data['email']);
//        if (user.data['email'] != loggedInUser.email) {
//          // populate checklist
//          checkList.add(false);
//        } else {
//          currUser = user;
//        }
//      }
//      // remove current used from users
//      users.remove(currUser);
//    });
//  }

  Card _buildCard(DocumentSnapshot user, int index) {
    final userCard = Card(
      margin: EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(
                    user.data['imgUrl'],
                  ),
                ),
              ],
            ),
            Flexible(
              child: CheckboxListTile(
                onChanged: (value) {
                  onCheckBoxChange(value, index);
                },
                title: Text(
                  user.data['name'],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
                subtitle: Text(
                  user.data['email'],
                  style: TextStyle(
                    fontSize: 10.0,
                  ),
                ),
                value: checkList[index],
              ),
            )
          ],
        ),
      ),
      elevation: 5.0,
    );
    return userCard;
  }

  onCheckBoxChange(bool value, int index) {
    // 1. set boolean value in checkList to new value
    // 2. if true, add user at index to selected users (if not there yet)
    // 3. if false, remove user from selected users
    setState(() {
      checkList[index] = value;
      if (value == true) {
        if (!selectedUsers.contains(users[index])) {
          selectedUsers.add(users[index]);
        }
      } else {
        // false
        selectedUsers.remove(users[index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select users'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: selectedUsers.length > 0 ? Colors.white : Colors.grey[600],
            ),
            onPressed: () async {
              if (selectedUsers.length > 0) {
                // get select IDs
                List<String> selectedIds = [];
                for (var u in selectedUsers) {
                  selectedIds.add(u.data['id']);
                }
                // add current user to selectedIds
                selectedIds.add(loggedInUser.uid);

                // create group
                DocumentReference ref = await _fireStore
                    .collection('groups')
                    .add({'_id': 'initialId'});
                // update new groups document
                ref.setData({
                  '_id': ref.documentID,
                  'createdAt': FieldValue.serverTimestamp(),
                  'groupIcon': 'testGroupIcon',
                  'lastTimeStamp': FieldValue.serverTimestamp(),
                  'members': selectedIds,
                  'chatName': chatName,
                });
                selectedIds = [];
                // open chat screen with messages from this group
                Navigator.pushNamed(
                  context,
                  ChatScreen.id,
                  arguments: ChatArguments(
                      chatName: chatName, groupId: ref.documentID),
                );
              }
            },
          ),
        ],
      ),
      body: users != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: TextField(
                    onChanged: (value) {
                      chatName = value;
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Chat name',
                      prefixIcon: Icon(Icons.message),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (ctx, index) {
                        DocumentSnapshot user = users[index];
                        return _buildCard(user, index);
                      }),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            ),
    );
  }
}
