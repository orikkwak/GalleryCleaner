// getlery/lib/models/screenshot_model.dart
import 'dart:io';

class ScreenshotInfo {
  final File file;
  final DateTime createdAt;

  ScreenshotInfo({
    required this.file,
    required this.createdAt,
  });

  // 스크린샷 정보가 JSON 형태로 변환될 수 있도록
  Map<String, dynamic> toJson() {
    return {
      'path': file.path,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // JSON에서 스크린샷 정보로 변환하는 생성자
  factory ScreenshotInfo.fromJson(Map<String, dynamic> json) {
    return ScreenshotInfo(
      file: File(json['path']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
