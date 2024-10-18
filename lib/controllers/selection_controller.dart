// 파일 위치: lib/controllers/selection_controller.dart

import 'package:get/get.dart';
import 'package:getlery/models/image_model.dart';
import 'package:getlery/services/image_service.dart';

class SelectionController extends GetxController {
  RxList<ImageModel> selectedItems = RxList<ImageModel>(); // 선택된 이미지 리스트
  RxBool isSelectMode = false.obs; // 선택 모드 활성화 여부
  final ImageService _imageService = ImageService(); // 이미지 서비스 참조

  // 이미지 선택/해제 기능
  void toggleSelection(ImageModel image) {
    if (selectedItems.contains(image)) {
      selectedItems.remove(image);
    } else {
      selectedItems.add(image);
    }
  }

  // 선택된 이미지 삭제
  Future<void> deleteSelectedImages() async {
    await _imageService.deleteSelectedImages(selectedItems);
    selectedItems.clear(); // 삭제 후 선택 항목 초기화
    isSelectMode.value = false; // 선택 모드 비활성화
  }

  // 선택 모드 초기화
  void clearSelection() {
    selectedItems.clear();
    isSelectMode.value = false;
  }

  // 선택 모드 활성화 여부
  void toggleSelectMode() {
    isSelectMode.value = !isSelectMode.value;
  }
}
