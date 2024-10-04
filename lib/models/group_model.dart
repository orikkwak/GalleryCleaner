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
  }) {
    // 생성자 내에서 NIMA 점수가 높은 이미지를 대표 이미지로 설정
    representativeImage ??= _selectRepresentativeImage();
  }

  // NIMA 점수 기반 대표 이미지 선택 함수
  ImageModel? _selectRepresentativeImage() {
    if (images.isEmpty) return null;

    // NIMA 점수가 가장 높은 이미지를 선택
    images.sort((a, b) {
      double nimaA = a.nimaScore ?? 0;
      double nimaB = b.nimaScore ?? 0;
      return nimaB.compareTo(nimaA);
    });

    return images.first; // 가장 높은 NIMA 점수를 가진 이미지 반환
  }

  // 대표 이미지의 썸네일을 가져오는 함수
  Future<Uint8List?> get representativeThumbnail async {
    if (representativeImage != null) {
      return await representativeImage!.assetEntity
          .thumbnailDataWithSize(const ThumbnailSize(200, 200));
    }
    return null;
  }
}
