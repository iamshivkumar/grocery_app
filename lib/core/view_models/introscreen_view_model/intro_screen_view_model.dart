import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreenViewModel extends ChangeNotifier {
  PageController controller = PageController();
  int pageIndex = 0;
  void setPage(int value) {
    pageIndex = value;
    notifyListeners();
  }

  Future<bool> seen() async {
    bool seen = await SharedPreferences.getInstance().then(
      (value) => value.getBool("seen"),
    );
    if (seen == null) {
      return false;
    } else
      return true;
  }

  void saveSeen() {
    SharedPreferences.getInstance().then(
      (value) => value.setBool("seen", true),
    );
  }
}
