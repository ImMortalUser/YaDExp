import 'package:flutter/foundation.dart';

class GlobalData extends ChangeNotifier {
  static String? accessToken;
  static String _currentPath = "disk:/";
  static List<String> _pathHistory = [];

  static String get currentPath => _currentPath;

  static set currentPath(String newPath) {
    if (_currentPath != newPath) {
      _pathHistory.add(_currentPath);
      _currentPath = newPath;
      _instance.notifyListeners();
    }
  }

  static List<String> get pathHistory => _pathHistory;

  static void goBack() {
    if (_pathHistory.isNotEmpty) {
      _currentPath = _pathHistory.removeLast();
      _instance.notifyListeners();
    }
  }

  static final GlobalData _instance = GlobalData._();

  factory GlobalData() => _instance;

  GlobalData._();
}
