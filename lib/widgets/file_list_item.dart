import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../utils/data.dart';
import '../utils/file_item_utils.dart';

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
          FileItemUtils.showFileContent(context, properties);
        } else {
          Data().currentPath = properties.path;
        }
      },
      onLongPress: () {
        FileItemUtils.showFileInfoDialog(context, properties);
      },
    );
  }
}
