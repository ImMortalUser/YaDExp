import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ya_disk_explorer/services/yandex_disk_service.dart';
import 'package:ya_disk_explorer/widgets/music_player_widget.dart';
import 'dart:io';

import '../utils/data.dart';
import '../models/file_item.dart';
import '../widgets/video_player_widget.dart';

class FileItemUtils {
  static Future<void> downloadFile(
      BuildContext context, FileItem properties) async {
    try {
      final encodedPath = Uri.encodeFull(properties.path);
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

  static void showFileInfoDialog(BuildContext context, FileItem properties) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(properties.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Type: ${properties.type}'),
                Text('Created at: ${properties.createdAt}'),
                Text(
                    'Size: ${properties.size != null ? properties.size.toString() : 'N/A'}'),
                Text('Media Type: ${properties.mediaType ?? 'N/A'}'),
                Text('Path: ${properties.path}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Download'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Download started...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                downloadFile(context, properties);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                deleteFile(context, properties);
              },
            ),
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

  static void _showDownloadSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Completed'),
          content: const Text('File successfully downloaded'),
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

  static Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  static void showFileContent(BuildContext context, FileItem properties) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(properties.name),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 200,
            ),
            child: properties.mediaType == "image"
                ? FutureBuilder<Uint8List>(
                    future: fetchPreviewImage(properties.previewUrl!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(child: Icon(Icons.error));
                      } else {
                        return Image.memory(snapshot.data!);
                      }
                    },
                  )
                : properties.mediaType == "video"
                    ? VideoPlayerWidget(videoUrl: properties.downloadUrl!)
                    : properties.mediaType == "audio"
                        ? MusicPlayerWidget(audioUrl: properties.downloadUrl!)
                        : const Text("Unsupported file format."),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<Uint8List> fetchPreviewImage(String previewUrl) async {
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
        throw Exception("Error with fetching image");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Image downloading failed");
    }
  }

  static Future<void> deleteFile(
      BuildContext context, FileItem properties) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Удаление файла началось...'),
          duration: Duration(seconds: 2),
        ),
      );

      bool success = await YandexDiskService.deleteFile(properties.path);

      if (success) {
        _showDeleteSuccessDialog(context);
        Data().refresh!();
      } else {
        _showDeleteFailureDialog(context);
      }

    } catch (e) {
      print('Ошибка при удалении: $e');
      _showDeleteFailureDialog(context);
    }
  }

  static void _showDeleteSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удаление прошло успешно'),
          content: const Text('Файл был удален с Яндекс.Диска.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void _showDeleteFailureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка при удалении'),
          content: const Text('Не удалось удалить файл.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
