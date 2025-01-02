import 'package:flutter/foundation.dart';

class Data extends ChangeNotifier {
  Function? _refresh;

  String? accessToken;
  String _currentPath = "disk:/";
  final List<String> _pathHistory = [];
  String _theme = "light";
  bool _bigIcons = false;

  String get currentPath => _currentPath;

  Function? get refresh => _refresh;

  List<String> get pathHistory => List.unmodifiable(_pathHistory);

  String get theme => _theme;

  bool get bigIcons => _bigIcons;

  set currentPath(String newPath) {
    if (_currentPath != newPath) {
      _pathHistory.add(_currentPath);
      _currentPath = newPath;
      notifyListeners();
    }
  }

  set refresh(Function? func) {
    _refresh = func;
  }

  void goBack() {
    if (_pathHistory.isNotEmpty) {
      _currentPath = _pathHistory.removeLast();
      notifyListeners();
    }
  }

  void switchTheme() {
    _theme = _theme == "light" ? "dark" : "light";
    notifyListeners();
  }

  void switchBigIcons() {
    _bigIcons = _bigIcons == true ? false : true;
    notifyListeners();
  }

  static final Data _instance = Data._();

  factory Data() => _instance;

  Data._();
}
