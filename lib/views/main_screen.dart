//D:\getlery\lib\views\main_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/controllers/group_controller.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'package:getlery/views/widgets/group_grid_screen.dart';
import 'package:getlery/views/widgets/photo_grid_screen.dart';
import 'package:getlery/views/setting_screen.dart';
import 'package:getlery/views/widgets/sort_option_bottom_sheet.dart';

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
            Text('Gallery (${controller.images.length})'), // 이미지 개수 표시
            IconButton(
              icon: const Icon(Icons.arrow_drop_down),
              onPressed: () async {
                // 날짜 범위 선택 기능
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

                  groupController.startDate.value = selectedRange.start;
                  groupController.endDate.value = selectedRange.end;

                  controller.fetchImages(); // 날짜에 맞춰 이미지 다시 불러오기
                  groupController.fetchImages(); // 날짜에 맞춰 그룹 다시 불러오기
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
                              controller.selectedItems.clear(); // 선택 해제
                              controller.isSelectMode.value = false;
                              Get.back();
                            },
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await controller
                                  .deleteSelectedImages(); // 선택된 이미지 삭제
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingScreen())); // 설정 화면 이동
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          groupController.minuteGroups; // 그룹 데이터 관찰
          return Stack(
            children: [
              ListView(
                children: [
                  SizedBox(
                    height: 160,
                    child: GroupGridScreen(), // 그룹 그리드 화면
                  ),
                  const SizedBox(height: 16),
                  PhotoGridScreen(), // 사진 그리드 화면
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
