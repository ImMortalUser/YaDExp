import 'package:flutter/material.dart';
import 'package:ya_disk_explorer/utils/data.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/file_item.dart';

class GridItem extends StatelessWidget {
  final FileItem properties;

  const GridItem({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (properties.type != "dir") {
          await _downloadFile(context, properties.path);
        } else {
          Data().currentPath = properties.path;
        }
      },
      onLongPress: () {
        _showFileInfoDialog(context);
      },
      child: GridTile(
        footer: Text(
          properties.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        child: properties.type == "dir"
            ? const Icon(Icons.folder, size: 100)
            : properties.previewUrl == null
                ? const Icon(Icons.file_copy, size: 100)
                : FutureBuilder<Uint8List>(
                    future: _fetchPreviewImage(properties.previewUrl!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Icon(Icons.error));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Icon(Icons.error));
                      } else {
                        return Image.memory(snapshot.data!);
                      }
                    },
                  ),
      ),
    );
  }

  Future<Uint8List> _fetchPreviewImage(String previewUrl) async {
    try {
      final response = await Dio().get(
        previewUrl,
        options: Options(
          headers: {
            'Authorization': 'OAuth ${Data().accessToken}',
            'Accept': 'application/json',
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Uint8List;
      } else {
        throw Exception('Ошибка при получении изображения');
      }
    } catch (e) {
      print('Ошибка при загрузке превью: $e');
      throw Exception('Не удалось загрузить превью');
    }
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
                Text(
                    'Size: ${properties.size != null ? properties.size.toString() : 'N/A'}'),
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

  Future<void> _downloadFile(BuildContext context, String path) async {
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
              _showDownloadSuccessDialog(context);
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
        print(
            'Ошибка при получении URL для скачивания: ${response.statusCode}');
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
