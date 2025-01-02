class DiskInfo {
  final int totalSpace;
  final int trashSize;
  final int usedSpace;

  DiskInfo({
    required this.totalSpace,
    required this.trashSize,
    required this.usedSpace,
  });

  factory DiskInfo.fromJson(Map<String, dynamic> json) {
    return DiskInfo(
      totalSpace: json['total_space'] ?? 0,
      trashSize: json['trash_size'] ?? 0,
      usedSpace: json['used_space'] ?? 0,
    );
  }
}
