// 파일 위치: lib/services/image_service.dart

import 'dart:io';
import 'package:get/get.dart';
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

// 이미지 삭제 예정 상태 업데이트
  Future<void> updateImageDeletionStatus(
      ImageModel image, bool isDeleteScheduled) async {
    image.isDeleteScheduled = isDeleteScheduled;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cached_images');

    if (cachedData != null) {
      List<dynamic> cachedImagesJson = jsonDecode(cachedData);
      cachedImagesJson = cachedImagesJson.map((json) {
        if (json['id'] == image.id) {
          json['isDeleteScheduled'] = isDeleteScheduled;
        }
        return json;
      }).toList();
      await prefs.setString('cached_images', jsonEncode(cachedImagesJson));
    }

    // 서버에 업데이트 전송
    if (await networkHelper.isServerConnected()) {
      if (isDeleteScheduled) {
        await _repository.scheduleImageDeletion(image.id);
      } else {
        await _repository.cancelImageDeletion(image.id);
      }
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

// 서버에서 삭제 예정 상태로 저장된 이미지를 로컬 캐시에 복구
  Future<void> restoreDeletedImagesFromServer() async {
    if (await networkHelper.isServerConnected()) {
      // 서버에서 삭제 예정 상태의 이미지 목록을 가져옴
      List<ImageModel> serverDeletedImages =
          (await _repository.fetchDeletedImages())
              .map((json) => ImageModel.fromJson(json))
              .toList();

      // 로컬 캐시에 저장된 이미지 목록을 가져옴
      final prefs = await SharedPreferences.getInstance();
      String? cachedData = prefs.getString('cached_images');
      List<dynamic> cachedImagesJson =
          cachedData != null ? jsonDecode(cachedData) : [];

      // 서버에서 가져온 삭제 예정 이미지를 로컬 캐시에 추가하여 복구
      for (var image in serverDeletedImages) {
        // 이미 로컬 캐시에 존재하지 않는 이미지만 추가
        if (!cachedImagesJson.any((cachedImg) => cachedImg['id'] == image.id)) {
          cachedImagesJson.add(image.toJson());
        }
      }
      Get.snackbar('Restored',
          'Images scheduled for deletion on the server have been restored to local storage.');
    }
  }

// 복구된 이미지를 로컬에 저장하는 메서드
  Future<void> saveImageLocally(ImageModel image) async {
    final prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cached_images');
    List<dynamic> cachedImagesJson =
        cachedData != null ? jsonDecode(cachedData) : [];
    cachedImagesJson.add(image.toJson());
    await prefs.setString('cached_images', jsonEncode(cachedImagesJson));
  }

  // 삭제 예정 이미지를 불러오는 메서드
  Future<List<ImageModel>> fetchScheduledImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cached_images');
    if (cachedData == null) return [];

    // 캐시에 저장된 이미지를 불러와서 삭제 예정 상태가 true인 이미지만 필터링
    List<dynamic> cachedImagesJson = jsonDecode(cachedData);
    List<ImageModel> scheduledImages = cachedImagesJson
        .map((json) => ImageModel.fromJson(json))
        .where((image) => image.isDeleteScheduled)
        .toList();

    return scheduledImages;
  }
}
