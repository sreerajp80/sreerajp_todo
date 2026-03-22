class BackupFileInfo {
  const BackupFileInfo({
    required this.filePath,
    required this.fileName,
    required this.createdAt,
    required this.fileSizeBytes,
  });

  final String filePath;
  final String fileName;
  final DateTime createdAt;
  final int fileSizeBytes;
}
