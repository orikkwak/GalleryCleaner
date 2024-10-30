// 파일 위치: C:\Users\Jenog\getlery\getlery_client\lib\views\delete_scheduled_images_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/views/main_screen.dart';

class ScheduledImagesScreen extends StatelessWidget {
  const ScheduledImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageController = Get.find<ImageController>();

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () =>
              Get.offAll(() => const MainScreen()), // 타이틀 터치시 메인화면으로 이동
          child: const Text('Scheduled for Deletion'),
        ),
      ),
      body: Obx(() {
        final scheduledImages = imageController.images
            .where((image) => image.isDeleteScheduled)
            .toList();
        if (scheduledImages.isEmpty) {
          return const Center(
            child: Text('No images scheduled for deletion'),
          );
        } else {
          return ListView.builder(
            itemCount: scheduledImages.length,
            itemBuilder: (context, index) {
              final image = scheduledImages[index];
              return ListTile(
                leading: Image.file(image.file!),
                title: Text('Scheduled for deletion'),
                subtitle: Text(image.createdAt.toString()),
              );
            },
          );
        }
      }),
    );
  }
}
