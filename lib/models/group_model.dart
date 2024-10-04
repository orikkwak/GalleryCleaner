import 'dart:typed_data';
import 'package:getlery/models/image_model.dart';
import 'package:photo_manager/photo_manager.dart';

class GroupModel {
  final DateTime groupKey;
  final List<ImageModel> images;
  late final ImageModel? representativeImage;

  GroupModel({
    required this.groupKey,
    required this.images,
    this.representativeImage,
  });

  Future<Uint8List?> get representativeThumbnail async {
    if (images.isNotEmpty) {
      return await images.first.assetEntity
          .thumbnailDataWithSize(const ThumbnailSize(200, 200));
    }
    return null;
  }
}
