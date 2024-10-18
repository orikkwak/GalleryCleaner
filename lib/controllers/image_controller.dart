// 파일 위치: lib/controllers/image_controller.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:getlery/models/image_model.dart';
import 'package:getlery/services/image_service.dart';
import 'package:getlery/services/nima_score_service.dart';

class ImageController extends GetxController {
  final ImageService _imageService = ImageService();
  final NimaScoreService _nimaScoreService = NimaScoreService();

  RxList<ImageModel> images = RxList<ImageModel>();
  RxBool isLoading = false.obs;

  // 날짜 필터
  Rx<DateTime> startDate =
      DateTime.now().subtract(const Duration(days: 10)).obs;
  Rx<DateTime> endDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchImages();
  }

  // 이미지 불러오기
  Future<void> fetchImages() async {
    isLoading.value = true;
    try {
      images.value =
          await _imageService.fetchImages(startDate.value, endDate.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch images: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 이미지 업로드
  Future<void> uploadImage(File imageFile) async {
    await _imageService.uploadImage(imageFile);
  }

  // 선택된 이미지 삭제
  Future<void> deleteSelectedImages() async {
    await _imageService.deleteSelectedImages(images);
    images.clear();
  }

  // NIMA 점수 업데이트
  Future<void> updateNimaScores() async {
    await _nimaScoreService.updateNimaScores(images);
  }

  // 이미지 정렬: 날짜 빠른순/느린순
  void sortImages(bool isNewestFirst) {
    if (isNewestFirst) {
      images.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      images.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    images.refresh();
  }
}
