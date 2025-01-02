import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../utils/data.dart';
import '../utils/file_item_utils.dart';

class GridItem extends StatelessWidget {
  final FileItem properties;

  const GridItem({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (properties.type != "dir") {
          FileItemUtils.showFileContent(context, properties);
        } else {
          Data().currentPath = properties.path;
        }
      },
      onLongPress: () {
        FileItemUtils.showFileInfoDialog(context, properties);
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
          future: FileItemUtils.fetchPreviewImage(properties.previewUrl!),
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
}
