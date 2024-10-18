// 파일 위치: lib/models/group_model.dart

import 'dart:typed_data';
import 'package:getlery/models/image_model.dart';
import 'package:photo_manager/photo_manager.dart';

class GroupModel {
  final DateTime groupKey;
  final List<ImageModel> images;
  ImageModel? representativeImage; // NIMA 점수 기반 대표 이미지 필드

  GroupModel({
    required this.groupKey,
    required this.images,
    this.representativeImage,
  }) {
    // 생성자에서 대표 이미지가 없으면 NIMA 점수를 기준으로 선택
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

  // A: fromJson 메서드 (JSON 데이터를 GroupModel로 변환)
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupKey: DateTime.parse(json['groupKey']),
      images: (json['images'] as List<dynamic>)
          .map((imageJson) => ImageModel.fromJson(imageJson))
          .toList(),
      representativeImage: json['representativeImage'] != null
          ? ImageModel.fromJson(json['representativeImage'])
          : null, // 대표 이미지가 있으면 변환
    );
  }

  // B: toJson 메서드 (GroupModel을 JSON으로 변환)
  Map<String, dynamic> toJson() {
    return {
      'groupKey': groupKey.toIso8601String(),
      'images': images.map((image) => image.toJson()).toList(),
      'representativeImage': representativeImage?.toJson(),
    };
  }
}
