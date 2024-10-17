// 파일 위치: lib/views/main_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/controllers/group_controller.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'package:getlery/utils/navigate_to_one_image.dart';
import 'package:getlery/widgets/grids/group_grid.dart';
import 'package:getlery/widgets/grids/image_grid.dart';
import 'package:getlery/views/setting_screen.dart';
import 'package:getlery/widgets/sort_option_bottom_sheet.dart';

class MainScreen extends GetView<ImageController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageController>();
    final groupController = Get.find<GroupController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Row(children: [
            Text('Gallery (${controller.images.length})'),
            IconButton(
              icon: const Icon(Icons.arrow_drop_down),
              onPressed: () async {
                final DateTimeRange? selectedRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDateRange: DateTimeRange(
                    start: controller.startDate.value,
                    end: controller.endDate.value,
                  ),
                );
                if (selectedRange != null) {
                  controller.startDate.value = selectedRange.start;
                  controller.endDate.value = selectedRange.end;
                  controller.fetchImages();
                  groupController.fetchImages();
                }
              },
            ),
          ]),
        ),
        actions: [
          Obx(() {
            return controller.selectedItems.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'Delete Images',
                        middleText:
                            'Are you sure you want to delete ${controller.selectedItems.length} images?',
                        actions: [
                          TextButton(
                            onPressed: () {
                              controller.selectedItems.clear();
                              controller.isSelectMode.value = false;
                              Get.back();
                            },
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await controller.deleteSelectedImages();
                              controller.isSelectMode.value = false;
                              Get.back();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  )
                : const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.to(() => SettingScreen()); // 수정: Navigator.push에서 Get.to로 변경
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              ListView(
                children: [
                  SizedBox(height: 160, child: GroupGrid()),
                  const SizedBox(height: 16),
                  ImageGrid(
                    images: controller.images.map((img) => img.file).toList(),
                    onTap: (index) => navigateToOneImageScreen(
                      context,
                      controller.images
                          .map((img) => img.file)
                          .whereType<File>()
                          .toList(),
                      index,
                    ),
                  ),
                ],
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
              imageController: Get.find<ImageController>(),
              groupController: Get.find<GroupController>(),
            ),
          );
        },
        child: const Icon(Icons.more_vert, color: Colors.white),
      ),
    );
  }
}
