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
import '../utils/app_localizations.dart'; // для локализации

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)
                      .translate("download_success")),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)
                      .translate("download_error")),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)
                    .translate("directory_not_found")),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)
                  .translate("download_url_not_found")),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate("download_url_error")
                .replaceFirst("{status}", response.statusCode.toString())),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate("download_error")
              .replaceFirst("{error}", e.toString())),
          duration: const Duration(seconds: 2),
        ),
      );
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
                ? FutureBuilder<Uint8List>( // Загрузка изображения
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
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate("file_deletion_started")),
          duration: const Duration(seconds: 2),
        ),
      );

      bool success = await YandexDiskService.deleteFile(properties.path, context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate("file_deletion_success")),
            duration: const Duration(seconds: 2),
          ),
        );
        Data().refresh!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate("file_deletion_error")),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Ошибка при удалении: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate("file_deletion_error")
              .replaceFirst("{error}", e.toString())),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
