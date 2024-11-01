// 파일 위치: lib/controllers/image_controller.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/category_controller.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/models/screenshot_model.dart';
import 'package:getlery_client/repositories/image_repository.dart';
import 'package:getlery_client/services/image_labeling_service.dart';
import 'package:getlery_client/services/image_service.dart';
import 'package:getlery_client/utils/network_helper.dart';
import 'package:getlery_client/utils/notification_helper.dart';
import 'package:getlery_client/utils/screenshot_manger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageController extends GetxController {
  final ImageService _imageService = ImageService();
  final RxList<ImageModel> images = RxList<ImageModel>();
  final RxList<ImageModel> scheduledForLocalDeletion =
      RxList<ImageModel>(); // 로컬 삭제 예정 이미지
  final RxList<ImageModel> scheduledForServerDeletion =
      RxList<ImageModel>(); // 서버 삭제 예정 이미지
  late NotificationHelper notificationHelper;
  late ScreenshotManager screenshotManager;
  var deletedImages = <ScreenshotInfo>[].obs;
  final isLoading = false.obs;
  int _currentPage = 0; // 페이징 인덱스
  late NetworkHelper networkHelper;
  late ImageRepository _repository;
  final RxList<ImageModel> scheduledForDeletion =
      RxList<ImageModel>(); // ImageModel로 타입 통일

  @override
  void onInit() {
    super.onInit();
    loadInitialImages(); // 앱 시작 시 초기 이미지를 로드
    loadScheduledImages(); // 삭제 예정 이미지 로드
  }

  // 초기 이미지 로딩: 캐시를 우선 불러오고, 최신 이미지를 가져옴
  Future<void> loadInitialImages() async {
    try {
      final cachedImages = await _imageService.loadImagesFromCache();
      if (cachedImages.isNotEmpty) {
        images.assignAll(cachedImages.where((img) =>
            !img.isDeleteScheduled && !img.isDeletedLocally)); // 삭제 예정 이미지 제외
      }
      await fetchNextPage(); // 기본 정렬 순서로 페이징 시작
    } catch (e) {
      Get.snackbar('Error', 'Failed to load images: $e');
    }
  }

  /// 삭제 예정 취소
  Future<void> cancelDeletion(ImageModel image) async {
    scheduledForDeletion.remove(image); // 삭제 예정에서 제거
    await updateImageDeletionStatus(
        image, false); // 삭제 상태를 false로 업데이트하고 서버 및 캐시 동기화
    Get.snackbar('Canceled', 'Screenshot deletion has been canceled.');
  }

  // 선택된 이미지 삭제 후 목록 새로고침
  Future<void> deleteSelectedImages(List<ImageModel> selectedImages) async {
    for (var image in selectedImages) {
      await updateImageDeletionStatus(
          image, true); // 삭제 예정 상태로 업데이트하고 서버와 캐시 동기화
    }
    await _imageService.deleteSelectedImages(selectedImages);
    images.removeWhere((img) => selectedImages.contains(img));
    await fetchNextPage();
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

  // ImageService에 있는 복구 로직을 통해 서버에서 삭제 예정인 이미지를 가져와 복구하는 메서드
  Future<void> restoreDeletedImagesFromServer() async {
    if (await networkHelper.isServerConnected()) {
      // 서버에서 삭제 예정인 이미지 데이터 가져오기
      List<ImageModel> serverDeletedImages =
          (await _repository.fetchDeletedImages())
              .map((json) => ImageModel.fromJson(json))
              .toList();

      for (var image in serverDeletedImages) {
        images.add(image);
        await _imageService.saveImageLocally(image); // 로컬에 저장
        updateImageDeletionStatus(
            image as ImageModel, false); // 삭제 예정 상태를 false로 업데이트
      }
      loadScheduledImages(); // 복구된 이미지 다시 로드
      Get.snackbar(
          'Restored', 'Deleted images have been restored from the server.');
    } else {
      Get.snackbar('Error', 'Failed to connect to the server');
    }
    await fetchNextPage();
  }

  // 삭제 상태에 따른 이미지 로드 및 구분
  Future<void> loadScheduledImages() async {
    try {
      scheduledForLocalDeletion.clear();
      scheduledForServerDeletion.clear();
      final scheduledImages = await _imageService.fetchScheduledImages();
      for (var image in scheduledImages) {
        if (image.isDeleteScheduled && !image.isDeletedLocally) {
          scheduledForLocalDeletion.add(image); // 로컬 삭제 예정
        } else if (image.isDeletedLocally) {
          scheduledForServerDeletion.add(image); // 서버 삭제 예정
        }
      }
      scheduledForLocalDeletion.refresh();
      scheduledForServerDeletion.refresh();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load scheduled images: $e');
    }
  }

  // 페이징을 통한 최신 이미지 불러오기 및 서버 업로드
  Future<void> fetchNextPage() async {
    isLoading.value = true;

    try {
      final newImages = await _imageService.fetchLocalImages(
          _currentPage); // 로컬에서 다음 페이지 이미지 불러오기 // 이미지 라벨링 및 카테고리화
      await _labelAndCategorizeImages(newImages);

      images.addAll(newImages); // 캐시에 저장
      await _imageService.saveImagesToCache(images);
      for (var image in newImages) {
        // 서버로 이미지 업로드
        final imageFile = File(image.filePath);
        if (await imageFile.exists()) {
          await uploadImageToServer(imageFile, image);
        }
      }

      _currentPage++;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load images: $e');
    } finally {
      isLoading.value = false;
    }
  }

// 이미지를 라벨링하고 카테고리에 추가하는 메서드
  Future<void> _labelAndCategorizeImages(List<ImageModel> images) async {
    final labelingService = ImageLabelingService();

    for (var image in images) {
      final labels = await labelingService.labelImage(File(image.filePath));

      // 각 이미지에 라벨을 설정
      image.labels = labels.cast<String>();

      // 카테고리 생성 또는 업데이트
      await _updateImageCategory(image);
    }
  }

// 이미지 라벨을 기반으로 카테고리 업데이트
  Future<void> _updateImageCategory(ImageModel image) async {
    final categoryController = Get.find<CategoryController>();
// 각 라벨마다 카테고리에 이미지 추가
    if (image.labels != null) {
      // labels가 null이 아닌지 확인
      for (var label in image.labels!) {
        // labels 뒤에 !를 붙여 null이 아님을 확정
        final category = categoryController.findOrCreateCategoryByLabel(label);
        await categoryController.addImageToCategory(category.id, image);
      }
    }
  }

  // 서버로 이미지 업로드 메서드 추가
  Future<void> uploadImageToServer(
      File imageFile, ImageModel imageModel) async {
    try {
      await _imageService.uploadImage(imageFile, imageModel);
      Get.snackbar('Success', 'Image uploaded successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
    }
  }

//정렬 걍 냅둬 얘는
  void sortImages(bool newestFirst) {
    images.sort((a, b) {
      if (newestFirst) {
        return b.createdAt.compareTo(a.createdAt);
      } else {
        return a.createdAt.compareTo(b.createdAt);
      }
    });
    images.refresh(); // UI에 변경 사항 반영
  }
}
