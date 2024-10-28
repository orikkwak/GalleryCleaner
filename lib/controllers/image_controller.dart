// 파일 위치: lib/controllers/image_controller.dart

import 'dart:io';

import 'package:get/get.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/services/image_service.dart';

class ImageController extends GetxController {
  final ImageService _imageService = ImageService();
  final RxList<ImageModel> images = RxList<ImageModel>();
  final isLoading = false.obs;
  final isImagesEmpty = false.obs;
  int _currentPage = 0; // 페이징 인덱스
  bool _isNewestFirst = true; // 정렬 기준

  @override
  void onInit() {
    super.onInit();
    loadInitialImages(); // 앱 시작 시 초기 이미지를 로드
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

  // 페이징을 통한 최신 이미지 불러오기
  Future<void> fetchNextPage() async {
    isLoading.value = true;

    try {
      final newImages = await _imageService.fetchLocalImages(_currentPage);
      images.addAll(newImages);
      await _imageService.saveImagesToCache(images); // 새로 불러온 이미지 캐시에 저장
      _currentPage++;
      isImagesEmpty.value = images.isEmpty;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load images: $e');
      isImagesEmpty.value = images.isEmpty;
    } finally {
      isLoading.value = false;
    }
  }

  // 이미지를 삭제하고 목록을 새로고침
  Future<void> deleteSelectedImages(List<ImageModel> selectedImages) async {
    await _imageService.deleteSelectedImages(selectedImages);
    _currentPage = 0; // 페이지 초기화
    images.clear(); // 목록 초기화 후 새로 불러오기
    await fetchNextPage();
  }

  // 정렬 방식 변경 후 이미지 로드
  void sortImages(bool isNewestFirst) {
    _isNewestFirst = isNewestFirst;
    _currentPage = 0;
    images.clear();
    fetchNextPage();
  }

  // ImageController에 파일 리스트를 변환해주는 메서드 추가
  Future<List<File>> getImageFiles() async {
    // 모든 Future<File?>을 기다린 후 null이 아닌 파일만 리스트로 반환
    List<File> files = [];
    for (var image in images) {
      final file = await image.file; // file은 Future<File?>
      if (file != null) {
        files.add(file);
      }
    }
    return files;
  }
}
