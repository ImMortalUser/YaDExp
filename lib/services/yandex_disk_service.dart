import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';  // для ScaffoldMessenger
import 'package:ya_disk_explorer/utils/data.dart';
import 'package:http/http.dart' as http;
import '../models/disk_info.dart';
import '../models/file_item.dart';
import 'package:ya_disk_explorer/utils/app_localizations.dart';  // Для локализации

class YandexDiskService {
  static final Map<String, List<FileItem>> _cache = {};

  static Future<List<FileItem>> getFilesList(
      {bool force = false, required String path, required BuildContext context}) async {
    if (!force && _cache.containsKey(path)) {
      return _cache[path]!;
    }

    try {
      String encodedPath = Uri.encodeComponent(path);

      final response = await http.get(
        Uri.parse(
            'https://cloud-api.yandex.net/v1/disk/resources?path=$encodedPath&'
                'fields=_embedded.items.name,_embedded.items.type,_embedded.items.path,_embedded.items.created,_embedded.items.size,_embedded.items.media_type,_embedded.items.preview,_embedded.items.file'),
        headers: {
          'Authorization': 'OAuth ${Data().accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['_embedded'] != null && data['_embedded']['items'] != null) {
          List<FileItem> files = [];
          for (var item in data['_embedded']['items']) {
            files.add(FileItem.fromJson(item));
          }

          _cache[path] = files;
          return files;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).translate("trash_load_error"))),
          );
          return [];
        }
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate("error_occurred").replaceFirst("{error}", error['message']))),
        );
        return [];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate("error_occurred").replaceFirst("{error}", e.toString().toString()))),
      );
      return [];
    }
  }

  static Future<bool> deleteFile(String path, BuildContext context) async {
    try {
      String encodedPath = Uri.encodeComponent(path);

      final response = await http.delete(
        Uri.parse(
            'https://cloud-api.yandex.net/v1/disk/resources?path=$encodedPath'),
        headers: {
          'Authorization': 'OAuth ${Data().accessToken}',
        },
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate("file_deleted"))),
        );
        _cache.remove(path);
        return true;
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate("error_occurred").replaceFirst("{error}", error['message']))),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate("error_occurred").replaceFirst("{error}", e.toString()))),
      );
      return false;
    }
  }

  static Future<DiskInfo?> getDiskInfo(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://cloud-api.yandex.net/v1/disk?fields=total_space,trash_size,used_space'),
        headers: {
          'Authorization': 'OAuth ${Data().accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DiskInfo.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate("error_occurred").replaceFirst("{error}", error['message']))),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate("error_occurred").replaceFirst("{error}", e.toString()))),
      );
      return null;
    }
  }

  static Future<bool> uploadFile(String filePath, BuildContext context) async {
    try {
      String encodedPath = Uri.encodeComponent(
          '${Data().currentPath}/${filePath.split('/').last}');

      final response = await Dio().get(
        'https://cloud-api.yandex.net/v1/disk/resources/upload?path=$encodedPath',
        options: Options(
          headers: {
            'Authorization': 'OAuth ${Data().accessToken}',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        String uploadUrl = response.data['href'];

        var file = File(filePath);
        final uploadResponse = await Dio().put(
          uploadUrl,
          data: file.openRead(),
          options: Options(
            headers: {'Authorization': 'OAuth ${Data().accessToken}'},
          ),
        );

        if (uploadResponse.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).translate("file_upload_success"))),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).translate("file_upload_error"))),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate("failed_to_get_link"))),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate("file_upload_error"))),
      );
      return false;
    }
  }

  static Future<List<FileItem>> getTrashFilesList(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('https://cloud-api.yandex.net/v1/disk/trash/resources'),
        headers: {
          'Authorization': 'OAuth ${Data().accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        List<FileItem> files = (data['_embedded']['items'] as List)
            .map((item) => FileItem.fromJson(item))
            .toList();
        return files;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate("trash_load_error"))),
        );
        throw Exception('Не удалось загрузить файлы из корзины');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate("error_occurred").replaceFirst("{error}", e.toString()))),
      );
      throw Exception('Ошибка: $e');
    }
  }

  static Future<bool> clearTrash({bool forceAsync = false, required BuildContext context}) async {
    try {
      final Uri uri =
      Uri.parse('https://cloud-api.yandex.net/v1/disk/trash/resources')
          .replace(queryParameters: {
        'force_async': forceAsync.toString(),
      });

      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'OAuth ${Data().accessToken}',
        },
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate("trash_clear_success"))),
        );
        return true;
      } else if (response.statusCode == 202) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate("trash_clear_async"))),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate("error_occurred").replaceFirst("{error}", response.body))),
        );
        throw Exception('Не удалось очистить корзину');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate("error_occurred").replaceFirst("{error}", e.toString()))),
      );
      throw Exception('Ошибка: $e');
    }
  }
}
