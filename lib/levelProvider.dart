import 'package:flutter/material.dart';

class LevelProvider with ChangeNotifier {
  int _level = 2;

  int get level => _level;

  set level(int newLevel) {
    if (_level != newLevel) {
      _level = newLevel;
      notifyListeners();
    }
  }
}
