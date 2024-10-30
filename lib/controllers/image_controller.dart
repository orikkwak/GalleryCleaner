// 파일 위치: lib/controllers/image_controller.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/category_controller.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/services/image_service.dart';

class ImageController extends GetxController {
  final ImageService _imageService = ImageService();
  final RxList<ImageModel> images = RxList<ImageModel>();
  final CategoryController _categoryController = Get.find<CategoryController>();
  final RxList<ImageModel> scheduledImages = RxList<
      ImageModel>(); // 삭제 예정 이미지 목록 추가final CategoryController _categoryController = Get.find<CategoryController>();

  final isLoading = false.obs;
  int _currentPage = 0; // 페이징 인덱스

  @override
  void onInit() {
    super.onInit();
    loadInitialImages(); // 앱 시작 시 초기 이미지를 로드
    loadScheduledImages();
  }

  // 초기 이미지 로딩: 캐시를 우선 불러오고, 최신 이미지를 가져옴
  Future<void> loadInitialImages() async {
    try {
      final cachedImages = await _imageService.loadImagesFromCache();
      if (cachedImages.isNotEmpty) {
        images.addAll(cachedImages);
      }
      await fetchNextPage(); // 기본 정렬 순서로 페이징 시작
    } catch (e) {
      Get.snackbar('Error', 'Failed to load images: $e');
    }
  }

  // 삭제 예정 이미지만 로드
  Future<List> loadScheduledImages() async {
    try {
      final scheduled = await _imageService.fetchScheduledImages();
      scheduledImages.addAll(scheduled);
      return scheduled; // 반환
    } catch (e) {
      Get.snackbar('Error', 'Failed to load scheduled images: $e');
      return []; // 오류 발생 시 빈 리스트 반환
    }
  }

  // 삭제 예정 이미지를 필터링하여 반환
  Future<List<ImageModel>> getScheduledImages() async {
    return images.where((image) => image.isDeleteScheduled).toList();
  }

  // 페이징을 통한 최신 이미지 불러오기 및 서버 업로드
  Future<void> fetchNextPage() async {
    isLoading.value = true;

    try {
      // 로컬에서 다음 페이지 이미지 불러오기
      final newImages = await _imageService.fetchLocalImages(_currentPage);

      // 캐시에 저장
      images.addAll(newImages);
      await _imageService.saveImagesToCache(images);

      // 서버로 이미지 업로드
      for (var image in newImages) {
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

  // 선택된 이미지 삭제 후 목록 새로고침
  Future<void> deleteSelectedImages(List<ImageModel> selectedImages) async {
    await _imageService.deleteSelectedImages(selectedImages);
    images.removeWhere((img) => selectedImages.contains(img));

    // 목록 새로고침
    await fetchNextPage(); // 또는 loadInitialImages()
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

  // 카테고리에 새로운 이미지 추가
  Future<void> addNewImageToCategory(
      String categoryId, ImageModel image) async {
    images.add(image);
    await _categoryController.addImageToCategory(categoryId, image);
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
