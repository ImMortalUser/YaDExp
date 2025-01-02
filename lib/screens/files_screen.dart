import 'package:flutter/material.dart';
import 'package:ya_disk_explorer/screens/settings_screen.dart';
import 'package:ya_disk_explorer/services/yandex_disk_service.dart';
import 'package:ya_disk_explorer/utils/settings_storage.dart';
import 'package:ya_disk_explorer/widgets/file_list_item.dart';
import '../models/file_item.dart';
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

  @override
  void initState() {
    super.initState();
    items = YandexDiskService.getFilesList(currentPath);
    Data().addListener(_onPathChanged);
    Data().addListener(_onBigIconsChanged);
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
        items = YandexDiskService.getFilesList(currentPath);
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
      items = YandexDiskService.getFilesList(currentPath);
    });
  }

  Future<bool> _onWillPop() async {
    if (Data().pathHistory.isNotEmpty) {
      Data().goBack();
      setState(() {
        currentPath = Data().currentPath;
        items = YandexDiskService.getFilesList(currentPath);
      });
      return false;
    }
    return true;
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
              ListTile(
                title: const Text('Выход'),
                onTap: () {},
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
                      items = YandexDiskService.getFilesList(currentPath);
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
        body: FutureBuilder<List<FileItem>>(
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
    );
  }
}
