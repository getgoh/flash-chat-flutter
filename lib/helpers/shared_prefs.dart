import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences prefs;

  static Future<void> saveLoggedInUser(
      {String id,
      String name,
      String imgUrl,
      String about,
      String email,
      List<String> groups}) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
    await prefs.setString('id', id);
    await prefs.setString('name', name);
    await prefs.setString('imgUrl', imgUrl);
    await prefs.setString('about', about);
    await prefs.setString('email', email);
    await prefs.setStringList('groups', groups);
  }

  static Future<User> getLoggedInUser() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    String id = prefs.getString('id');
    String name = prefs.getString('name');
    String imgUrl = prefs.getString('imgUrl');
    String about = prefs.getString('about');
    String email = prefs.getString('email');
    List<String> groups = prefs.getStringList('groups');

    return User(
        email: email,
        id: id,
        about: about,
        name: name,
        imgUrl: imgUrl,
        groups: groups);
  }
}
