import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/components/input_text_field.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/helpers/shared_prefs.dart';
import 'package:flash_chat/screens/chat_list_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = Firestore.instance;
  bool showSpinner = false;
  String email;
  String password;
  String aboutMe;
  String name;
  String imgUrl =
      'https://avatars3.githubusercontent.com/u/22161412?s=400&u=17d683b09765f988487f6878c1190a9877dabaa5&v=4';

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
                    child: Image.asset(
                      'images/logo.png',
                    ),
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
                height: 8.0,
              ),
              InputTextField(
                hintText: 'Enter your nickname',
                prefixIcon: Icons.font_download,
                onTextChanged: (value) {
                  name = value;
                },
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                onChanged: (value) {
                  aboutMe = value;
                },
                textAlign: TextAlign.center,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                style: kTextFieldTextStyle,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 15),
                  hintText: 'Enter description',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.blueAccent, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: Colors.blueAccent,
                title: 'Register',
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);

                    if (newUser != null) {
                      print('user not null');
                      print(newUser.user.uid);

//                      final QuerySnapshot result = await _fireStore
//                          .collection('users')
//                          .where('id', isEqualTo: newUser.user.uid)
//                          .getDocuments();

                      // add user info
                      _fireStore
                          .collection('users')
                          .document(newUser.user.uid)
                          .setData(
                        {
                          'name': name,
                          'id': newUser.user.uid,
                          'about': aboutMe,
                          'imgUrl': imgUrl,
                          'email': email
                        },
                      );

                      SharedPrefs.saveLoggedInUser(
                        id: newUser.user.uid,
                        imgUrl: imgUrl,
                        email: email,
                        name: name,
                        about: aboutMe,
                        groups: [],
                      );

                      Navigator.pushNamed(context, ChatListScreen.id);
                    } else {
                      print('user null');
                    }
                  } on PlatformException catch (ex) {
                    String authError = 'x';
                    switch (ex.code) {
                      case 'ERROR_INVALID_EMAIL':
                        {
                          authError = 'Invalid email address format.';
                        }
                        break;
                      case 'ERROR_EMAIL_ALREADY_IN_USE':
                        {
                          authError =
                              'Email address entered is already in use.';
                          break;
                        }
                      case 'ERROR_WEAK_PASSWORD':
                        {
                          authError =
                              'Password not strong enough. Please enter at least 6 characters.';
                        }
                        break;
                      default:
                        {
                          authError =
                              'An error has occurred. Please try again later.';
                        }
                        break;
                    }
                    showDialog(
                      context: context,
                      child: AlertDialog(
                        content: Text(
                          authError,
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    );
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
