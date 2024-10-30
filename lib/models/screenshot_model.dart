// ScreenshotInfo 모델
import 'dart:io';

class ScreenshotInfo {
  final String filePath; // file 대신 경로를 저장
  final DateTime createdAt;

  ScreenshotInfo({
    required this.filePath,
    required this.createdAt,
  });

  // 스크린샷 정보를 JSON 형태로 변환
  Map<String, dynamic> toJson() {
    return {
      'path': filePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // JSON에서 스크린샷 정보로 변환하는 생성자
  factory ScreenshotInfo.fromJson(Map<String, dynamic> json) {
    return ScreenshotInfo(
      filePath: json['path'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // File 객체로 변환하는 헬퍼 메서드 추가
  File get file => File(filePath);
}
