import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/views/one_image_screen.dart';
import 'package:getlery_client/widgets/image_loader.dart';

class ZoomableImageGrid extends StatefulWidget {
  final List<Future<File?>> images;

  const ZoomableImageGrid({
    super.key,
    required this.images,
  });

  @override
  ZoomableImageGridState createState() => ZoomableImageGridState();
}

class ZoomableImageGridState extends State<ZoomableImageGrid> {
  double _scale = 1.0;
  final selectionController = Get.find<SelectionController>();
  final imageController = Get.find<ImageController>();

  // 이미지를 클릭했을 때 OneImageScreen으로 이동하는 함수
  void _openOneImageScreen(BuildContext context, int index) async {
    if (!selectionController.isSelectMode.value) {
      List<File> imageFiles = await imageController.getImageFiles();
      Get.to(() => OneImageScreen(
            imageFileList: imageFiles,
            initialIndex: index,
          ));
    } else {
      _toggleSelectionMode(imageController.images[index]);
    }
  }

  // 이미지를 길게 눌렀을 때 선택 모드 활성화 함수
  void _toggleSelectionMode(ImageModel image) {
    if (!selectionController.isSelectMode.value) {
      selectionController.toggleSelectMode(); // 선택 모드 활성화
    }
    selectionController.toggleSelection(image);
  }

  // 선택된 이미지 스타일 적용
  Widget _buildImageItem(int index) {
    return Obx(() {
      final image = imageController.images[index];
      final isSelected = selectionController.selectedItems.contains(image);

      return GestureDetector(
        onTap: () => _openOneImageScreen(context, index),
        onLongPress: () => _toggleSelectionMode(image),
        onPanUpdate: (details) {
          if (selectionController.isSelectMode.value) {
            _toggleSelectionMode(image);
          }
        },
        child: Opacity(
          opacity: isSelected ? 0.6 : 1.0,
          child: ImageLoader(imageFuture: widget.images[index]),
        ),
      );
    });
  }

  // 선택된 이미지 삭제
  void _deleteSelectedImages() {
    Get.defaultDialog(
      title: 'Delete Images',
      middleText: 'Are you sure you want to delete selected images?',
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await selectionController.deleteSelectedImages();
            Get.back();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectionController.isSelectMode.value) {
          selectionController.clearSelection();
          return false; // 선택 모드 상태에서는 뒤로 가기 제한
        }
        return true; // 일반 상태에서는 뒤로 가기 허용
      },
      child: Scaffold(
        appBar: selectionController.isSelectMode.value
            ? AppBar(
                title: Obx(() => Text(
                    'Selected: ${selectionController.selectedItems.length}')),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteSelectedImages,
                  ),
                ],
              )
            : null,
        body: GestureDetector(
          onScaleUpdate: (details) {
            setState(() {
              _scale = (_scale * details.scale).clamp(1.0, 3.0);
            });
          },
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (3 / _scale).round().clamp(1, 5),
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return _buildImageItem(index);
            },
          ),
        ),
      ),
    );
  }
}
