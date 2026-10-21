import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

ImageProvider? teacherImageProvider(String? photoUrl) {
  if (photoUrl == null) return null;
  final url = photoUrl.trim();
  if (url.isEmpty) return null;
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return NetworkImage(url);
  }
  return FileImage(File(url));
}

String teacherInitials(String? name) {
  final parts = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'D';
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

Future<String> persistTeacherPhoto({
  required String sourcePath,
  required String teacherId,
}) async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/profile');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final destPath = '${dir.path}/$teacherId${_fileExtension(sourcePath)}';
  await File(sourcePath).copy(destPath);
  return destPath;
}

String _fileExtension(String path) {
  final dot = path.lastIndexOf('.');
  if (dot <= 0 || dot == path.length - 1) return '.jpg';
  final ext = path.substring(dot).toLowerCase();
  const allowed = {'.jpg', '.jpeg', '.png', '.webp', '.heic', '.gif'};
  return allowed.contains(ext) ? ext : '.jpg';
}
