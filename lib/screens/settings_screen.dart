import 'package:flutter/material.dart';
import 'package:ya_disk_explorer/utils/data.dart';
import 'package:ya_disk_explorer/widgets/setting_list_item.dart';

import '../utils/settings_storage.dart';

enum Theme { light, dark }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SettingItem(
            name: "Dark theme",
            onTap: () {
              Data().switchTheme();
              SettingsStorage.saveTheme(Data().theme);
            },
            initValue: Data().theme == "light" ? false : true,
          ),
          SettingItem(
            name: "Big icons",
            onTap: () {
              Data().switchBigIcons();
              SettingsStorage.saveBigIcons(Data().bigIcons);
            },
            initValue: Data().bigIcons == true ? true : false,
          ),
        ],
      ),
    );
  }
}
