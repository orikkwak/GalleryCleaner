import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/models/image_model.dart';
import 'package:getlery/views/image_grid_screen.dart'; // 새로운 ImageGridScreen
import 'package:photo_manager/photo_manager.dart';

class ImageController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ImageModel> images = RxList<ImageModel>();

  @override
  void onInit() {
    super.onInit();
    fetchImages();
  }

  Future<void> fetchImages() async {
    isLoading.value = true;
    try {
      final FilterOptionGroup filterOptionGroup = FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      );

      final List<AssetEntity> assetEntities =
          await PhotoManager.getAssetListRange(
        start: 0,
        end: 1000,
        filterOption: filterOptionGroup,
      ).then((result) => result.cast<AssetEntity>());

      images.value = assetEntities.map((assetEntity) {
        return ImageModel(
          id: assetEntity.id,
          assetEntity: assetEntity,
          createdAt: assetEntity.createDateTime ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch images');
    } finally {
      isLoading.value = false;
    }
  }

  void handleTap(int index) async {
    final imageFileList = await Future.wait(images.map((image) => image.file));
    Get.to(() => ImageGridScreen(
          imageFileList: imageFileList.whereType<File>().toList(),
          initialIndex: index,
        ));
  }
}
