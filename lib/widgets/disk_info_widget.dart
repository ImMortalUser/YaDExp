import 'package:flutter/material.dart';
import '../models/disk_info.dart';

class DiskInfoWidget extends StatelessWidget {
  final DiskInfo diskInfo;

  const DiskInfoWidget({Key? key, required this.diskInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double usedSpacePercentage = diskInfo.totalSpace > 0
        ? diskInfo.usedSpace / diskInfo.totalSpace
        : 0;

    double trashSpacePercentage = diskInfo.totalSpace > 0
        ? diskInfo.trashSize / diskInfo.totalSpace
        : 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Информация о диске',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildSpaceUsageInfo(
            context,
            'Использованное пространство',
            diskInfo.usedSpace,
            diskInfo.totalSpace,
            usedSpacePercentage,
          ),
          const SizedBox(height: 16),
          _buildTrashInfo(context),
        ],
      ),
    );
  }

  Widget _buildSpaceUsageInfo(
      BuildContext context,
      String title,
      int currentSize,
      int totalSize,
      double percentage,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ${_formatSize(currentSize)} / ${_formatSize(totalSize)}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 8),
        Text(
          'Занято: ${(percentage * 100).toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTrashInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Размер корзины: ${_formatSize(diskInfo.trashSize)}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  String _formatSize(int size) {
    if (size >= 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (size >= 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (size >= 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$size bytes';
    }
  }
}
