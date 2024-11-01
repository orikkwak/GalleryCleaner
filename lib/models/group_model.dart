import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/models/image_selector.dart';

class GroupModel {
  final DateTime groupKey;
  final String uniqueID; // 고유성을 위한 추가 필드
  final List<ImageModel> images;
  ImageModel? representativeImage; // NIMA 점수 기반 대표 이미지 필드

  GroupModel({
    required this.groupKey,
    required this.images,
    this.representativeImage,
  }) : uniqueID = '${groupKey.millisecondsSinceEpoch}-${images.length}';

  // // 대표 이미지의 썸네일을 가져오는 함수
  // Future<Uint8List?> get representativeThumbnail async {
  //   if (representativeImage != null) {
  //     return await representativeImage!.assetEntity
  //         .thumbnailDataWithSize(const ThumbnailSize(200, 200));
  //   }
  //   return null;
  // }

  // 대표 이미지의 파일 경로를 반환하는 함수
  String? get representativeImagePath {
    return representativeImage?.filePath;
  }

  void selectRepresentativeByNima() {
    images.sort((a, b) => (b.nimaScore ?? 0).compareTo(a.nimaScore ?? 0));
    representativeImage = images.first;
  }

  Future<void> selectRepresentativeByPixels() async {
    representativeImage = await ImageSelector.selectRepresentativeImage(images);
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupKey: DateTime.parse(json['groupKey']),
      images: (json['images'] as List<dynamic>)
          .map((imageJson) => ImageModel.fromJson(imageJson))
          .toList(),
      representativeImage: json['representativeImage'] != null
          ? ImageModel.fromJson(json['representativeImage'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupKey': groupKey.toIso8601String(),
      'images': images.map((image) => image.toJson()).toList(),
      'representativeImage': representativeImage?.toJson(),
      'uniqueID': uniqueID,
    };
  }
}
