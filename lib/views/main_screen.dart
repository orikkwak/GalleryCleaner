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
import 'package:intl/intl.dart';

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
                  //showDateRangePicker여기에서 달력 디테일한부분 수정해야함.
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
                // 선택된 날짜 범위에 해당하는 이미지의 총 개수를 계산
                final startDate = controller.startDate.value;
                final endDate = controller.endDate.value;
                int totalImages = 0;
                for (var photo in controller.images) {
                  final imageDate = photo.createdAt;
                  if (imageDate.isAfter(startDate) &&
                      imageDate.isBefore(endDate)) {
                    totalImages++;
                  }
                }

                // 사용자에게 정보 표시를 위한 다이얼로그 표시
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
                        // const SizedBox(height: 8),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('cancel'.tr),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.fetchImages(); // 여기를 수정했습니다.
                          Navigator.pop(context);
                        },
                        child: Text('show'.tr),
                      ),
                    ],
                  ),
                  //다이얼로그 여기까지
                );
              },
            ),
          ]),
        ),
        actions: [
          GetX<ImageController>(builder: (controller) {
            //Obx를 Getx로 고침
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
              Get.to(() => const SettingScreen());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          groupController.minuteGroups; // 앨범 데이터 변경 감지
          return Stack(
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
              //원래 childre안에 있던 코드임.
              // ListView(
              //   children: [
              //     Container(
              //       height: 160,
              //       child: const GroupGridScreen(),
              //     ),
              //     const SizedBox(height: 16),
              //     const PhotoGridScreen(),
              //   ],
              // ),
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
