// 파일 위치: lib/widgets/grids/zoomable_image_grid.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/utils/navigate_to_one_image.dart';
import 'package:getlery_client/widgets/image_loader.dart';

class ZoomableImageGrid extends StatefulWidget {
  final List<ImageModel> images;
  final bool showScheduledOnly; // 삭제 예정 이미지만 표시할지 여부

  const ZoomableImageGrid({
    super.key,
    required this.images,
    this.showScheduledOnly = false,
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
      List<File> imageFiles = widget.images
          .where((img) => widget.showScheduledOnly
              ? img.isDeleteScheduled
              : !img.isDeleteScheduled)
          .map((img) => File(img.filePath))
          .toList();

      navigateToOneImageScreen(context, imageFiles, index);
    } else {
      _toggleSelectionMode(widget.images[index]);
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
      final image = widget.images[index];
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
          child: ImageLoader(imageFuture: Future.value(File(image.filePath))),
        ),
      );
    });
  }

  // 선택된 이미지 삭제
  void _deleteSelectedImages() {
    if (selectionController.selectedItems.isNotEmpty) {
      Get.defaultDialog(
        title: 'Delete Images',
        middleText:
            'Are you sure you want to delete ${selectionController.selectedItems.length} images?',
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // 선택된 이미지 삭제 요청
              await imageController
                  .deleteSelectedImages(selectionController.selectedItems);
              selectionController.clearSelection(); // 선택 초기화
              Get.back();
              setState(() {}); // 목록 갱신
            },
            child: const Text('Delete'),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (selectionController.isSelectMode.value) {
          selectionController.clearSelection();
          selectionController.isSelectMode.value = false;
          return true; // 선택 모드를 해제하고 이전 화면으로 이동
        }
        return true; // 일반 상태에서는 그대로 이전 화면으로 이동
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
