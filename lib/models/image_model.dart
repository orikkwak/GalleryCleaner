import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageModel {
  final String id;
  final AssetEntity assetEntity;
  final DateTime createdAt;
  Uint8List? _thumbnailData;
  File? _file;

  ImageModel({
    required this.id,
    required this.assetEntity,
    required this.createdAt,
    Uint8List? thumbnailData,
  });

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
