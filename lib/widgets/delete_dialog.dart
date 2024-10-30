import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';

class DeleteDialog extends StatelessWidget {
  final SelectionController selectionController;
  final ImageController imageController = Get.find<ImageController>();

  DeleteDialog({super.key, required this.selectionController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (selectionController.selectedItems.isNotEmpty) {
        return IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            Get.defaultDialog(
              title: 'Delete Images',
              middleText:
                  'Are you sure you want to delete ${selectionController.selectedItems.length} images?',
              actions: [
                TextButton(onPressed: Get.back, child: const Text('No')),
                TextButton(
                  onPressed: () async {
                    await imageController.deleteSelectedImages(
                      selectionController.selectedItems.toList(),
                    );
                    Get.back();
                    selectionController.clearSelection(); // 선택 초기화
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
