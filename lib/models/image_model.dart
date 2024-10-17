// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';

class ImageModel {
  final String id;
  final AssetEntity assetEntity;
  final DateTime createdAt;
  Uint8List? _thumbnailData;
  File? _file;
  double? nimaScore; // NIMA 점수 필드 추가

  ImageModel({
    required this.id,
    required this.assetEntity,
    required this.createdAt,
    this.nimaScore, // NIMA 점수 추가
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
    };
  }

  // 이미지의 썸네일 데이터를 불러오는 함수
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

  // 이미지 파일을 로드하는 함수
  Future<File?> get file async {
    if (_file == null) {
      try {
        _file = await assetEntity.file;
      } catch (e) {
        print("Failed to load file: $e");
        _file = null;
      }
    }
    return _file;
  }
}
