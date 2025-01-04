import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ya_disk_explorer/models/disk_info.dart';
import 'package:ya_disk_explorer/screens/sign_in_screen.dart';
import 'package:ya_disk_explorer/services/yandex_disk_service.dart';
import 'package:ya_disk_explorer/utils/settings_storage.dart';
import 'package:ya_disk_explorer/widgets/disk_info_widget.dart';
import 'package:ya_disk_explorer/widgets/file_list_item.dart';
import '../models/file_item.dart';
import '../services/file_picker.dart';
import '../utils/app_localizations.dart';
import '../utils/data.dart';
import '../widgets/file_greed_item.dart';
import '../widgets/setting_list_item.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  late Future<List<FileItem>> items;
  String currentPath = Data().currentPath;
  bool bigIcons = Data().bigIcons;
  late Future<DiskInfo?> diskInfo;

  @override
  void initState() {
    super.initState();
    items = _loadItems();
    diskInfo = YandexDiskService.getDiskInfo(context);
    Data().addListener(_onPathChanged);
    Data().addListener(_onBigIconsChanged);
    Data().addListener(_onLangChanged);
    Data().refresh = _reloadData;
  }

  @override
  void dispose() {
    Data().removeListener(_onPathChanged);
    Data().removeListener(_onBigIconsChanged);
    Data().removeListener(_onLangChanged);
    super.dispose();
  }

  Future<List<FileItem>> _loadItems() {
    return currentPath.startsWith("trash")
        ? YandexDiskService.getTrashFilesList(context)
        : YandexDiskService.getFilesList(path: currentPath, context: context);
  }

  void _onPathChanged() {
    if (Data().currentPath != currentPath) {
      setState(() {
        currentPath = Data().currentPath;
        items = _loadItems();
      });
    }
  }

  void _onBigIconsChanged() {
    if (Data().bigIcons != bigIcons) {
      setState(() {
        bigIcons = Data().bigIcons;
      });
    }
  }

  void _onLangChanged() {
    setState(() {
    });
  }

  void _reloadData() {
    setState(() {
      items = _loadItems();
      diskInfo = YandexDiskService.getDiskInfo(context);
    });
  }

  Future<bool> _onWillPop() async {
    if (Data().pathHistory.isNotEmpty) {
      Data().goBack();
      setState(() {
        currentPath = Data().currentPath;
        items = _loadItems();
      });
      return false;
    }
    return true;
  }

  Future<void> _onRefresh() async {
    _reloadData();
  }

  Future<void> _clearTrash() async {
    bool success = await YandexDiskService.clearTrash(context: context);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('trash_cleared')),
        ),
      );
      _reloadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('trash_clear_error')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: Drawer(
          backgroundColor: Theme.of(context).primaryColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(height: 80),
              FutureBuilder<DiskInfo?>(
                future: diskInfo,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Text(AppLocalizations.of(context).translate('disk_info_error')),
                    );
                  } else {
                    return DiskInfoWidget(diskInfo: snapshot.data!);
                  }
                },
              ),
              Container(
                height: 5,
                width: 100,
                color: Theme.of(context).primaryColorDark,
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).translate('disk')),
                onTap: () {
                  Data().currentPath = "disk:/";
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).translate('trash')),
                onTap: () {
                  Data().currentPath = "trash:/";
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).translate('sign_in_screen')),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
              ),
              SettingItem(
                name: AppLocalizations.of(context).translate('dark_theme'),
                onTap: () {
                  Data().switchTheme();
                  SettingsStorage.saveTheme(Data().theme);
                },
                initValue: Data().theme == "dark",
              ),
              SettingItem(
                name: AppLocalizations.of(context).translate('big_icons'),
                onTap: () {
                  Data().switchBigIcons();
                  SettingsStorage.saveBigIcons(Data().bigIcons);
                },
                initValue: Data().bigIcons,
              ),
              SettingItem(
                name: AppLocalizations.of(context).translate('enable_english'),
                onTap: () {
                  Data().switchLang();
                  SettingsStorage.saveLang(Data().isEng);
                },
                initValue: Data().isEng,
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            if (currentPath.startsWith('trash'))
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: _clearTrash,
              ),
            IconButton(
              onPressed: () async {
                File? file = await FilePickerService.pickFile();
                if (file != null) {
                  bool success = await YandexDiskService.uploadFile(file.path, context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).translate('file_uploaded')),
                      ),
                    );
                    _reloadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).translate('file_upload_error')),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).translate('file_not_selected')),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<int>(
              onSelected: (value) {
                switch (value) {
                  case 0:
                    _reloadData();
                    break;
                  case 1:
                    Data().currentPath = "disk:/";
                    setState(() {
                      currentPath = Data().currentPath;
                      items = currentPath.startsWith("trash")
                          ? YandexDiskService.getTrashFilesList(context)
                          : YandexDiskService.getFilesList(path: currentPath, context: context);
                    });
                    break;
                  case 2:
                    SettingsStorage.removeToken();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  value: 0,
                  child: Text(AppLocalizations.of(context).translate('refresh')),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Text(AppLocalizations.of(context).translate('home')),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Text(AppLocalizations.of(context).translate('delete_token')),
                ),
              ],
            ),
          ],
          title: Text(currentPath),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: FutureBuilder<List<FileItem>>(
            future: items,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('${AppLocalizations.of(context).translate('error')}: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text(AppLocalizations.of(context).translate('no_files')));
              }

              final files = snapshot.data!;
              return bigIcons
                  ? GridView.builder(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  return GridItem(properties: files[index]);
                },
              )
                  : ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  return ListItem(properties: files[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
