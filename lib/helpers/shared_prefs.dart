import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences prefs;

  static Future<void> saveLoggedInUser(DocumentSnapshot user) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
    await prefs.setString('id', user['id']);
    await prefs.setString('name', user['name']);
    await prefs.setString('imgUrl', user['imgUrl']);
    await prefs.setString('about', user['about']);
    await prefs.setString('email', user['email']);
  }

  static Future<User> getLoggedInUser() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    String id = await prefs.getString('id');
    String name = await prefs.getString('name');
    String imgUrl = await prefs.getString('imgUrl');
    String about = await prefs.getString('about');
    String email = await prefs.getString('email');

    return User(email: email, id: id, about: about, name: name, imgUrl: imgUrl);
  }
}
