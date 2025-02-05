import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? userId;
  String? email;
  String? name;

  void setUserData(String id, String userEmail, String userName) {
    userId = id;
    email = userEmail;
    name = userName;
    notifyListeners();
  }

  void clearUser() {
    userId = null;
    email = null;
    name = null;
    notifyListeners();
  }
}
