import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/components/input_text_field.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/helpers/shared_prefs.dart';
import 'package:flash_chat/screens/chat_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = Firestore.instance;
  bool showSpinner = false;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              InputTextField(
                hintText: 'Enter your email',
                inputType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
                onTextChanged: (value) {
                  email = value;
                },
              ),
              SizedBox(
                height: 8.0,
              ),
              InputTextField(
                hintText: 'Enter your password',
                obscureText: true,
                prefixIcon: FontAwesomeIcons.eye,
                onTextChanged: (value) {
                  password = value;
                },
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: Colors.lightBlueAccent,
                title: 'Log In',
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (user != null) {
                      // get user from 'users' documents
                      final QuerySnapshot result = await _fireStore
                          .collection('users')
                          .where('id', isEqualTo: user.user.uid)
                          .getDocuments();

                      DocumentSnapshot fsUser = result.documents[0];

                      // save user info to sharedPref
                      SharedPrefs.saveLoggedInUser(
                        id: fsUser['id'],
                        imgUrl: fsUser['imgUrl'],
                        email: fsUser['email'],
                        name: fsUser['name'],
                        about: fsUser['about'],
                        groups: List.castFrom(fsUser['groups'] ?? []),
                      );

                      Navigator.pushNamed(context, ChatListScreen.id);
                    }
                  } catch (ex) {
                    print(ex);
                  }

                  setState(() {
                    showSpinner = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
