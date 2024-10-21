// 파일 위치: lib/views/main_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/controllers/group_controller.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'package:getlery/controllers/selection_controller.dart';
import 'package:getlery/utils/navigate_to_one_image.dart';
import 'package:getlery/widgets/delete_dialog.dart';
import 'package:getlery/widgets/grids/image_grid.dart';
import 'package:getlery/widgets/grids/group_grid.dart';
import 'package:getlery/views/setting_screen.dart';
import 'package:getlery/widgets/sort_option_bottom_sheet.dart';
import 'package:intl/intl.dart';

class MainScreen extends GetView<ImageController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ImageController>(); // ImageController 자동 주입
    final groupController =
        Get.find<GroupController>(); // GroupController 자동 주입
    final selectionController =
        Get.find<SelectionController>(); // SelectionController 자동 주입

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Row(
            children: [
              Text('Gallery (${controller.images.length})'),
              IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: () async {
                  final DateTimeRange? selectedRange =
                      await showDateRangePicker(
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
                  }

                  final startDate = controller.startDate.value;
                  final endDate = controller.endDate.value;
                  int totalImages = controller.images
                      .where((photo) =>
                          photo.createdAt.isAfter(startDate) &&
                          photo.createdAt.isBefore(endDate))
                      .length;

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Image Show'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${DateFormat('yyyy/MM/dd').format(startDate)} - ${DateFormat('yyyy/MM/dd').format(endDate)}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('cancel'.tr),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.fetchImages();
                            Navigator.pop(context);
                          },
                          child: Text('show'.tr),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          DeleteDialog(selectionController: selectionController), // 삭제 다이얼로그 추가
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.to(() => const SettingScreen());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // 그룹 컨트롤러의 그룹 목록 사용
          groupController.groups;

          return Stack(
            children: [
              SizedBox(height: 160, child: GroupGrid()), // 그룹 그리드 표시
              const SizedBox(height: 16),
              ZoomableImageGrid(
                // ImageGrid 대신 ZoomableImageGrid로 교체
                key: ValueKey("ZoomableImageGrid-${controller.images.length}"),
                images: controller.images
                    .map((img) => img.file)
                    .toList(), // 이미지 파일 리스트 전달
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
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SortOptionBottomSheet(
              imageController: controller, // ImageController 사용
              groupController: groupController, // GroupController 사용
            ),
          );
        },
        child: const Icon(Icons.more_vert, color: Colors.white),
      ),
    );
  }
}
