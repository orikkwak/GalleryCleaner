import 'dart:io';
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
import 'package:intl/intl.dart';

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
              const SizedBox(height: 160, child: GroupGrid()),
              const SizedBox(height: 16),
              if (imageController.images.isEmpty)
                const Center(
                    child: Text('이미지가 없습니다.',
                        style: TextStyle(fontSize: 18, color: Colors.grey)))
              else
                ZoomableImageGrid(
                  images:
                      imageController.images.map((img) => img.file).toList(),
                  // onTap: (index) =>
                  //     _showImageDialog(context, imageController, index),
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

  // void _showImageDialog(
  //     BuildContext context, ImageController controller, int index) async {
  //   final DateTimeRange? selectedRange = await showDateRangePicker(
  //     context: context,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2100),
  //     initialDateRange: DateTimeRange(
  //         start: controller.startDate.value, end: controller.endDate.value),
  //   );

  //   if (selectedRange != null) {
  //     controller.startDate.value = selectedRange.start;
  //     controller.endDate.value = selectedRange.end;
  //     controller.fetchImages();
  //   }

  //   final startDate = controller.startDate.value;
  //   final endDate = controller.endDate.value;
  //   Get.dialog(
  //     AlertDialog(
  //       title: const Text('Image Show'),
  //       content: Text(
  //           '${DateFormat('yyyy/MM/dd').format(startDate)} - ${DateFormat('yyyy/MM/dd').format(endDate)}'),
  //       actions: [
  //         TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
  //         TextButton(
  //             onPressed: () => controller.fetchImages(),
  //             child: Text('show'.tr)),
  //       ],
  //     ),
  //   );
  // }
}
