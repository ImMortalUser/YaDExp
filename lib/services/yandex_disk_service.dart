import 'dart:convert';
import 'package:ya_disk_explorer/utils/data.dart';
import 'package:http/http.dart' as http;
import '../models/disk_info.dart';
import '../models/file_item.dart';

class YandexDiskService {
  static final Map<String, List<FileItem>> _cache = {};

  static Future<List<FileItem>> getFilesList({bool force = false, required String path}) async {
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
          print("Нет данных о файлах в указанной папке");
          return [];
        }
      } else {
        final error = jsonDecode(response.body);
        print("Ошибка: ${error['message']}");
        return [];
      }
    } catch (e) {
      print('Ошибка при выполнении запроса: $e');
      return [];
    }
  }

  static Future<bool> deleteFile(String path) async {
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
        print("Файл удален успешно.");
        _cache.remove(path);
        return true;
      } else {
        final error = jsonDecode(response.body);
        print("Ошибка: ${error['message']}");
        return false;
      }
    } catch (e) {
      print('Ошибка при выполнении запроса: $e');
      return false;
    }
  }

  static Future<DiskInfo?> getDiskInfo() async {
    try {
      final response = await http.get(
        Uri.parse('https://cloud-api.yandex.net/v1/disk?fields=total_space,trash_size,used_space'),
        headers: {
          'Authorization': 'OAuth ${Data().accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DiskInfo.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        print("Ошибка при получении информации о диске: ${error['message']}");
        return null;
      }
    } catch (e) {
      print('Ошибка при выполнении запроса: $e');
      return null;
    }
  }
}
