// 파일 위치: lib/services/image_service.dart

import 'dart:io';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/repositories/image_repository.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ImageService {
  final ImageRepository _repository = ImageRepository();
  static const int _pageSize = 150; // 한 번에 가져올 이미지 수

  // 로컬 이미지 페이징 및 정렬하여 가져오기
  Future<List<ImageModel>> fetchLocalImages(int pageIndex,
      {bool isNewestFirst = true}) async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      throw Exception('Permission denied');
    }

    final List<AssetEntity> localAssets = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    ).then((paths) =>
        paths[0].getAssetListPaged(page: pageIndex, size: _pageSize));

    // 정렬 설정
    localAssets.sort((a, b) => isNewestFirst
        ? b.createDateTime.compareTo(a.createDateTime)
        : a.createDateTime.compareTo(b.createDateTime));

    return localAssets
        .map((asset) => ImageModel(
              id: asset.id,
              assetEntity: asset,
              createdAt: asset.createDateTime,
            ))
        .toList();
  }

  // 이미지 캐시에 저장
  Future<void> saveImagesToCache(List<ImageModel> images) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> imagesJson =
        images.map((image) => image.toJson()).toList();
    await prefs.setString('cached_images', jsonEncode(imagesJson));
  }

  // 캐시에서 이미지 불러오기
  Future<List<ImageModel>> loadImagesFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cached_images');
    if (cachedData == null) return [];
    List<dynamic> cachedImagesJson = jsonDecode(cachedData);
    return cachedImagesJson.map((json) => ImageModel.fromJson(json)).toList();
  }

  // 서버에 이미지 업로드
  Future<void> uploadImage(File imageFile) async {
    await _repository.uploadImageToServer(imageFile);
  }

  // 서버와 로컬에서 이미지 삭제
  Future<void> deleteSelectedImages(List<ImageModel> images) async {
    for (var image in images) {
      await _repository.deleteImageFromServer(image.id);
      final localFile = await image.file;
      if (localFile != null) {
        localFile.deleteSync();
      }
    }
  }
}
