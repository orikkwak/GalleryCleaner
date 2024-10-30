// 파일 위치: lib/models/image_model.dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';

class ImageModel {
  final String id;
  final AssetEntity assetEntity;
  final DateTime createdAt;
  Uint8List? _thumbnailData;
  double? nimaScore; // NIMA 점수 필드 
  final String filePath; // 로컬 파일 경로 필드 추가 (문자열로 저장)
  bool isDeleteScheduled; // 삭제 예정 상태 필드 추가

  ImageModel({
    required this.id,
    required this.assetEntity,
    required this.createdAt,
    this.nimaScore, // NIMA 점수 추가
    required this.filePath, // filePath 필수 매개변수로 변경
    this.isDeleteScheduled = false, // 기본값으로 false 설정
    Uint8List? thumbnailData,
  });

  // JSON 데이터를 통해 ImageModel 객체 생성 (NIMA 점수 포함)
  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      assetEntity: AssetEntity(
        id: json['id'],
        typeInt: json['typeInt'], // 필수 매개변수
        width: json['width'], // 필수 매개변수
        height: json['height'], // 필수 매개변수
        duration: json['duration'] ?? 0,
        orientation: json['orientation'] ?? 0,
        isFavorite: json['isFavorite'] ?? false,
        title: json['title'],
        createDateSecond: json['createDateSecond'],
        modifiedDateSecond: json['modifiedDateSecond'],
        relativePath: json['relativePath'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        mimeType: json['mimeType'],
        subtype: json['subtype'] ?? 0,
      ),
      nimaScore: json['nimaScore'], // NIMA 점수 추가
      filePath: json['filePath'] ?? '', // filePath 추가
      isDeleteScheduled: json['isDeleteScheduled'] ?? false,
    );
  }

  // ImageModel 객체를 JSON으로 변환 (NIMA 점수 포함)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'typeInt': assetEntity.typeInt,
      'width': assetEntity.width,
      'height': assetEntity.height,
      'duration': assetEntity.duration,
      'orientation': assetEntity.orientation,
      'isFavorite': assetEntity.isFavorite,
      'title': assetEntity.title,
      'createDateSecond': assetEntity.createDateSecond,
      'modifiedDateSecond': assetEntity.modifiedDateSecond,
      'relativePath': assetEntity.relativePath,
      'latitude': assetEntity.latitude,
      'longitude': assetEntity.longitude,
      'mimeType': assetEntity.mimeType,
      'subtype': assetEntity.subtype,
      'nimaScore': nimaScore, // NIMA 점수 포함
      'filePath': filePath, // filePath 추가
      'isDeleteScheduled': isDeleteScheduled,
    };
  }

  // 썸네일 데이터를 가져오는 함수 (Lazy Loading 적용)
  Future<Uint8List?> get thumbnailData async {
    if (_thumbnailData == null) {
      try {
        _thumbnailData = await assetEntity.thumbnailDataWithSize(
          const ThumbnailSize(256, 256),
        );
      } catch (e) {
        print("Failed to load thumbnail: $e");
        _thumbnailData = null;
      }
    }
    return _thumbnailData;
  }

  // 파일 경로를 사용하여 File 객체를 반환
  File get file => File(filePath);
}
