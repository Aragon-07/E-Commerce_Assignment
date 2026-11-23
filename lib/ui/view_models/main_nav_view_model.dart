import 'package:flutter/foundation.dart';

/// Tracks active tab index for the bottom navigation bar.
class MainNavViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  void backToHome() {
    setIndex(0);
  }
}
