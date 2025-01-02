import 'package:flutter/material.dart';
import 'package:ya_disk_explorer/services/yandex_disk_service.dart';
import 'package:ya_disk_explorer/utils/token_storage.dart';
import 'package:ya_disk_explorer/widgets/item.dart';
import '../models/file_item.dart';
import '../utils/global_data.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  late Future<List<FileItem>> items;
  String currentPath = GlobalData.currentPath;

  @override
  void initState() {
    super.initState();
    items = YandexDiskService.getFilesList(currentPath);
    GlobalData().addListener(_onPathChanged);
  }

  @override
  void dispose() {
    GlobalData().removeListener(_onPathChanged);
    super.dispose();
  }

  void _onPathChanged() {
    if (GlobalData.currentPath != currentPath) {
      setState(() {
        currentPath = GlobalData.currentPath;
        items = YandexDiskService.getFilesList(currentPath);
      });
    }
  }

  void _reloadData() {
    setState(() {
      items = YandexDiskService.getFilesList(currentPath);
    });
  }

  Future<bool> _onWillPop() async {
    if (GlobalData.pathHistory.isNotEmpty) {
      GlobalData.goBack();
      setState(() {
        currentPath = GlobalData.currentPath;
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
              const DrawerHeader(
                child: Text('Меню'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: const Text('Настройки'),
                onTap: () {},
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
                    GlobalData.currentPath = "disk:/";
                    setState(() {
                      currentPath = GlobalData.currentPath;
                      items = YandexDiskService.getFilesList(currentPath);
                    });
                    break;
                  case 2:
                    TokenStorage.removeToken();
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

            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                return Item(properties: files[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
