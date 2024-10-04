import 'dart:io';
import 'package:get/get.dart';
import 'package:getlery/models/image_model.dart';
import 'package:getlery/services/image_service.dart';
import 'package:getlery/views/one_image_screen.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ImageModel> images = RxList<ImageModel>();
  final ImageService _imageService = ImageService(); // 이미지 서비스 추가

  @override
  void onInit() {
    super.onInit();
    fetchImages();
  }

  // 로컬 저장소에서 이미지 불러오기
  Future<void> fetchImages() async {
    isLoading.value = true;
    try {
      final filterOptionGroup = FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      );

      final List<AssetEntity> assetEntities =
          await PhotoManager.getAssetListRange(
        start: 0,
        end: 1000, // 페이징 처리 가능
        filterOption: filterOptionGroup,
      );

      images.value = assetEntities.map((assetEntity) {
        return ImageModel(
          id: assetEntity.id,
          assetEntity: assetEntity,
          createdAt: assetEntity.createDateTime,
        );
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch images: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 서버로 이미지 업로드 처리
  Future<void> uploadImagesToServer() async {
    isLoading.value = true;
    try {
      List<String> imagePaths = [];

      for (var image in images) {
        File? imageFile = await image.file;
        if (imageFile != null) {
          imagePaths.add(imageFile.path);
        }
      }

      await _imageService.uploadImages(imagePaths);
      Get.snackbar('Success', 'Images uploaded successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload images: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 이미지 선택 및 상세 화면으로 이동
  void handleTap(int index) async {
    final File? imageFile = await images[index].file;
    if (imageFile != null) {
      // Get.toNamed 호출 시 imageFile과 index 전달
      Get.toNamed('/image', arguments: {
        'photoFile': imageFile,
        'initialIndex': index,
      });
    }
  }
}
