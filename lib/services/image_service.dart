// 파일 위치: lib/services/image_service.dart

import 'dart:io';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/repositories/image_repository.dart';
import 'package:getlery_client/utils/network_helper.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ImageService {
  final ImageRepository _repository = ImageRepository();
  static const int _pageSize = 150; // 한 번에 가져올 이미지 수
  final networkHelper = NetworkHelper();

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
              filePath: asset.relativePath ?? '', // 파일 경로 추가
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

  // 서버에 이미지 업로드 (중복 체크 포함)
  Future<void> uploadImage(File imageFile, ImageModel image) async {
    final isConnected = await NetworkHelper().isServerConnected();
    if (isConnected) {
      // 서버에 이미지 중복 확인
      final isDuplicate = await _repository.checkDuplicateImage(image.id);
      if (!isDuplicate) {
        // 중복이 아니라면 업로드 진행
        await _repository.uploadImageToServer(imageFile);
      } else {
        print('Duplicate image, skipping upload');
      }
    } else {
      print('Server is not connected, skipping upload');
    }
  }

  // 서버와 로컬에서 이미지 삭제 (중복 확인 포함)
  Future<void> deleteSelectedImages(List<ImageModel> images) async {
    final isConnected = await NetworkHelper().isServerConnected();

    for (var image in images) {
      bool isDeletedFromServer = false;

      // 서버와 연결된 상태인 경우 서버에서 중복 확인 후 삭제 시도
      if (isConnected) {
        final isDuplicateOnServer =
            await _repository.checkDuplicateImage(image.id);

        if (isDuplicateOnServer) {
          await _repository.deleteImageFromServer(image.id);
          isDeletedFromServer = true;
          print('Image deleted from server: ${image.id}');
        } else {
          // 서버에만 존재하는 이미지의 경우 삭제 예정으로 스케줄 설정
          await _repository.scheduleImageDeletion(image.id);
        }
      }

      // 서버에서 삭제되지 않은 경우 로컬에서만 삭제
      if (!isDeletedFromServer) {
        final localFile = File(image.filePath);
        if (await localFile.exists()) {
          await localFile.delete();
          print('Image deleted from local storage: ${image.filePath}');
        }
      }
    }
  }

  // 카테고리 이름 업데이트
  Future<void> updateCategoryName(String id, String newName) async {
    // PUT 요청을 통해 서버의 카테고리 이름 업데이트
    await networkHelper.putRequest(
      '${networkHelper.categoryApiUrl}/$id',
      {'name': newName},
    );
  }

  // 카테고리에 이미지 추가
  Future<void> addImageToCategory(String categoryId, String imageUrl) async {
    // POST 요청을 통해 서버의 카테고리에 이미지 추가
    await networkHelper.postRequest(
      '${networkHelper.categoryApiUrl}/$categoryId/add-image',
      {'imageUrl': imageUrl},
    );
  }

  // 삭제 예정 이미지를 불러오는 메서드
  Future<List<ImageModel>> fetchScheduledImages() async {
    // 여기에 실제로 삭제 예정 이미지를 불러오는 로직을 구현하세요.
    // 예시로, 삭제 예정 상태가 true로 설정된 이미지들을 반환하도록 합니다.

    final List<ImageModel> scheduledImages = []; // 이 리스트에 삭제 예정 이미지를 추가하세요.

    // 예시로 캐시에서 삭제 예정 이미지 정보를 불러오는 방식:
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('scheduled_'));

    for (var key in keys) {
      final imageData = prefs.getString(key);
      if (imageData != null) {
        // `imageData`를 JSON 파싱하여 `ImageModel`로 변환
        final image = ImageModel.fromJson(imageData as Map<String, dynamic>);
        scheduledImages.add(image);
      }
    }

    return scheduledImages;
  }
}
