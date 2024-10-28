import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';
import 'package:getlery_client/views/setting_screen.dart';
import 'package:getlery_client/widgets/delete_dialog.dart';
import 'package:getlery_client/widgets/grids/group_grid.dart';
import 'package:getlery_client/widgets/grids/zoomable_image_grid.dart';
import 'package:getlery_client/widgets/sort_option_bottom_sheet.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageController = Get.find<ImageController>();
    final groupController = Get.find<GroupController>();
    final selectionController = Get.find<SelectionController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Gallery (${imageController.images.length})')),
        actions: [
          DeleteDialog(selectionController: selectionController),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              const SizedBox(height: 160, child: GroupGrid()), // 그룹 그리드
              const SizedBox(height: 16),
              if (imageController.images.isEmpty)
                const Center(
                    child: Text('이미지가 없습니다.',
                        style: TextStyle(fontSize: 18, color: Colors.grey)))
              else
                ZoomableImageGrid(
                  images:
                      imageController.images.map((img) => img.file).toList(),
                ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SortOptionBottomSheet(
              imageController: imageController,
              groupController: groupController,
            ),
          );
        },
        child: const Icon(Icons.more_vert, color: Colors.white),
      ),
    );
  }
}
