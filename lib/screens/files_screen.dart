import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ya_disk_explorer/models/disk_info.dart';
import 'package:ya_disk_explorer/screens/settings_screen.dart';
import 'package:ya_disk_explorer/services/yandex_disk_service.dart';
import 'package:ya_disk_explorer/utils/settings_storage.dart';
import 'package:ya_disk_explorer/widgets/disk_info_widget.dart';
import 'package:ya_disk_explorer/widgets/file_list_item.dart';
import '../models/file_item.dart';
import '../services/file_picker.dart';
import '../utils/data.dart';
import '../widgets/file_greed_item.dart';

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
    items = YandexDiskService.getFilesList(path: currentPath);
    diskInfo = YandexDiskService.getDiskInfo();
    Data().addListener(_onPathChanged);
    Data().addListener(_onBigIconsChanged);
    Data().refresh = _reloadData;
  }

  @override
  void dispose() {
    Data().removeListener(_onPathChanged);
    Data().removeListener(_onBigIconsChanged);
    super.dispose();
  }

  void _onPathChanged() {
    if (Data().currentPath != currentPath) {
      setState(() {
        currentPath = Data().currentPath;
        items = YandexDiskService.getFilesList(path: currentPath);
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

  void _reloadData() {
    setState(() {
      items = YandexDiskService.getFilesList(path: currentPath, force: true);
      diskInfo = YandexDiskService.getDiskInfo();
    });
  }

  Future<bool> _onWillPop() async {
    if (Data().pathHistory.isNotEmpty) {
      Data().goBack();
      setState(() {
        currentPath = Data().currentPath;
        items = YandexDiskService.getFilesList(path: currentPath);
      });
      return false;
    }
    return true;
  }

  Future<void> _onRefresh() async {
    _reloadData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 80,
              ),
              FutureBuilder<DiskInfo?>(
                  future: diskInfo,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                        child: Text("Не удалось загрузить информацию о диске"),
                      );
                    } else {
                      return DiskInfoWidget(diskInfo: snapshot.data!);
                    }
                  }),
              ListTile(
                title: const Text('Настройки'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () async {
                File? file = await FilePickerService.pickFile();

                if (file != null) {
                  bool success = await YandexDiskService.uploadFile(file.path);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Файл успешно загружен!')),
                    );
                    _reloadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ошибка загрузки файла.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Файл не выбран.')),
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
                      items = YandexDiskService.getFilesList(
                          path: currentPath, force: false);
                    });
                    break;
                  case 2:
                    SettingsStorage.removeToken();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text('Обновить'),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text('Домой'),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text('Удалить токен'),
                ),
              ],
            ),
          ],
          title: Text(currentPath),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh, // Добавляем метод обновления
          child: FutureBuilder<List<FileItem>>(
            future: items,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Нет файлов.'));
              }

              final files = snapshot.data!;

              return bigIcons == false
                  ? ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  return ListItem(properties: files[index]);
                },
              )
                  : GridView.builder(
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
              );
            },
          ),
        ),
      ),
    );
  }
}
