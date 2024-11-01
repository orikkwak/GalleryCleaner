// 파일 위치: lib/widgets/main_content.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/widgets/grids/group_grid.dart';
import 'package:getlery_client/widgets/grids/zoomable_image_grid.dart';

class MainContent extends StatelessWidget {
  final ImageController imageController;

  const MainContent({super.key, required this.imageController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          const SizedBox(height: 160, child: GroupGrid()), // 그룹 그리드
          const SizedBox(height: 16),
          if (imageController.images.isEmpty)
            const Center(
              child: Text(
                '이미지가 없습니다.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          else
            ZoomableImageGrid(
              images: imageController.images
                  .where((img) => !img.isDeleteScheduled)
                  .toList(),
              showScheduledOnly: false,
            ),
        ],
      );
    });
  }
}
