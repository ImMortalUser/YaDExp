import 'dart:ffi';

class FileItem {
  final String name;
  final String type;
  final String path;
  final String createdAt;
  final int? size;
  final String? mediaType;
  final String? previewUrl;

  FileItem(
      {required this.name,
      required this.type,
      required this.path,
      required this.createdAt,
      required this.size,
      required this.mediaType,
      required this.previewUrl,});

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      name: json['name'],
      type: json['type'],
      path: json['path'],
      createdAt: json['created'],
      size: json['size'],
      mediaType: json['media_type'],
      previewUrl: json['preview'],
    );
  }
}
