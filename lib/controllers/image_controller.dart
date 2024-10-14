import 'dart:io';
import 'package:get/get.dart';
import 'package:getlery/models/image_model.dart';
import 'package:getlery/services/image_service.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ImageModel> images = RxList<ImageModel>();
  final ImageService _imageService = ImageService();

  // 선택된 이미지 리스트 (이미지 삭제 시 사용)
  RxList<ImageModel> selectedItems = RxList<ImageModel>();
  RxBool isSelectMode = false.obs;

  // 날짜 필터
  Rx<DateTime> startDate =
      (DateTime.now().subtract(const Duration(days: 10))).obs;
  Rx<DateTime> endDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchImages();
    syncWithServer(); // 앱 실행 시 서버 동기화 호출
  }

  // 로컬 저장소에서 이미지 불러오기
  Future<void> fetchImages() async {
    isLoading.value = true;
    try {
      final filterOptionGroup = FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        createTimeCond: DateTimeCond(
          min: startDate.value,
          max: endDate.value,
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

  // 선택된 이미지 삭제
  Future<void> deleteSelectedImages() async {
    isLoading.value = true;
    try {
      for (var image in selectedItems) {
        await _imageService.deleteImage(image.id);
        // NIMA 점수 캐시에서 해당 이미지의 점수 삭제
        await _imageService.deleteNimaScoreFromCache(image.id);
      }
      images.removeWhere((image) => selectedItems.contains(image));
      Get.snackbar('Success', 'Selected images deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete images: $e');
    } finally {
      isLoading.value = false;
      selectedItems.clear();
    }
  }

  // 서버와 주기적으로 동기화하는 로직
  Future<void> syncWithServer() async {
    try {
      // 서버에서 현재 이미지를 불러와 비교
      final serverImages = await _imageService.fetchImagesFromServer();
      final serverImageIds = serverImages.map((img) => img.id).toSet();
      // 로컬에 없는 이미지를 서버에서 삭제
      for (var serverImage in serverImages) {
        if (!images.any((localImage) => localImage.id == serverImage.id)) {
          await _imageService.deleteImage(serverImage.id);
        }
      }

      // 클라이언트에서 서버에 없는 이미지는 서버에 업로드
      for (var image in images) {
        if (!serverImageIds.contains(image.id)) {
          await uploadImagesToServer();
        }
      }

      Get.snackbar('Success', 'Images synchronized with server');
    } catch (e) {
      Get.snackbar('Error', 'Failed to synchronize images: $e');
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
      final nimaScores = await _imageService.uploadImages(imagePaths);

      // NIMA 점수를 캐시에 저장
      for (var entry in nimaScores.entries) {
        await _imageService.cacheNimaScore(entry.key, entry.value);
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
      Get.toNamed('/image', arguments: {
        'photoFile': imageFile,
        'initialIndex': index,
      });
    }
  }

  // 이미지 정렬 기능
  void sortImages(bool newestFirst) {
    images.sort((a, b) {
      if (newestFirst) {
        return b.createdAt.compareTo(a.createdAt);
      } else {
        return a.createdAt.compareTo(b.createdAt);
      }
    });
  }
}
