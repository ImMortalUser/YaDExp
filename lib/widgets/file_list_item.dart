import 'package:flutter/material.dart';
import 'package:ya_disk_explorer/utils/data.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/file_item.dart';

class ListItem extends StatelessWidget {
  final FileItem properties;

  const ListItem({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: properties.type == "dir"
          ? const Icon(Icons.folder)
          : const Icon(Icons.file_copy),
      title: Text(properties.name),
      onTap: () async {
        if (properties.type != "dir") {
          await _downloadFile(context,properties.path);
        } else {
          Data().currentPath = properties.path;
        }
      },
      onLongPress: () {
        _showFileInfoDialog(context);
      },
    );
  }

  void _showFileInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(properties.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Type: ${properties.type}'),
                Text('Path: ${properties.path}'),
                Text('Created at: ${properties.createdAt}'),
                Text('Size: ${properties.size != null ? properties.size.toString() : 'N/A'}'),
                Text('Media Type: ${properties.mediaType ?? 'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadFile(BuildContext context, String path) async {  // Передаем context
    try {
      final encodedPath = Uri.encodeFull(path);
      final response = await Dio().get(
        'https://cloud-api.yandex.net/v1/disk/resources/download?path=$encodedPath',
        options: Options(
          headers: {
            'Authorization': 'OAuth ${Data().accessToken}',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final downloadUrl = response.data['href'];

        if (downloadUrl != null) {
          final directory = await _getDownloadDirectory();
          if (directory != null) {
            final filePath = '${directory.path}/${properties.name}';
            final fileResponse = await Dio().download(downloadUrl, filePath);
            if (fileResponse.statusCode == 200) {
              _showDownloadSuccessDialog(context);  // Показываем всплывающее окно о успешной загрузке
            } else {
              print('Не удалось скачать файл');
            }
          } else {
            print('Не найдена директория для загрузки');
          }
        } else {
          print('Не найден URL для скачивания');
        }
      } else {
        print('Ошибка при получении URL для скачивания: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при загрузке: $e');
    }
  }


  void _showDownloadSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Успех!'),
          content: const Text('Файл успешно загружен.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Закрыть'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }
}
