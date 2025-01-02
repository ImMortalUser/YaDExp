import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ya_disk_explorer/screens/files_screen.dart';
import 'package:ya_disk_explorer/screens/sign_in_screen.dart';
import 'package:ya_disk_explorer/utils/data.dart';
import 'package:ya_disk_explorer/utils/settings_storage.dart';
import 'package:ya_disk_explorer/widgets/video_player.dart';

bool hasToken = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSettings();
  runApp(MyApp(hasToken: hasToken));
}

Future<void> loadSettings() async {
  String? token = await SettingsStorage.loadToken();
  if (token != null) {
    hasToken = true;
    Data().accessToken = token;
  }
  String? theme = await SettingsStorage.loadTheme();
  if (theme != null && theme != "light") {
    Data().switchTheme();
  }
  bool? bigIcons = await SettingsStorage.loadBigIcons();
  if (bigIcons != null && bigIcons != false) {
    Data().switchBigIcons();
  }
}

class MyApp extends StatelessWidget {
  final bool hasToken;
  final Data data = Data();

  MyApp({super.key, required this.hasToken});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => data,
      child: Consumer<Data>(builder: (context, data, child) {
        return MaterialApp(
          theme: data.theme == "light" ? ThemeData.light() : ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          home: const VideoPlayerScreen(),
          //hasToken ? const FilesScreen() : SignInScreen(),
        );
      }),
    );
  }
}
