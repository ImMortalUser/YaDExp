import 'package:flutter/material.dart';
import 'package:ya_disk_explorer/screens/files_screen.dart';
import 'package:ya_disk_explorer/screens/sign_in_screen.dart';
import 'package:ya_disk_explorer/utils/global_data.dart';
import 'package:ya_disk_explorer/utils/token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool hasToken = false;
  String? token = await TokenStorage.loadToken();

  if (token != null) {
    hasToken = true;
    GlobalData.accessToken = token;
  }

  runApp(MyApp(hasToken: hasToken));
}

class MyApp extends StatelessWidget {
  final bool hasToken;

  const MyApp({super.key, required this.hasToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: hasToken ? const FilesScreen() : SignInScreen(),
    );
  }
}
