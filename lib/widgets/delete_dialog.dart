// 파일 위치: lib/widgets/delete_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/controllers/selection_controller.dart';

class DeleteDialog extends StatelessWidget {
  final SelectionController selectionController;

  const DeleteDialog({Key? key, required this.selectionController})
      : super(key: key);

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
                TextButton(
                  onPressed: () {
                    selectionController.clearSelection();
                    Get.back();
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    await selectionController.deleteSelectedImages();
                    Get.back(); // 다이얼로그 닫기
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
