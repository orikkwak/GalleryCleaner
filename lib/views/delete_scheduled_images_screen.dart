// 파일 위치: lib/views/delete_scheduled_images_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/models/screenshot_model.dart';
import 'package:getlery_client/views/main_screen.dart';

class ScheduledImagesScreen extends StatelessWidget {
  const ScheduledImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageController = Get.find<ImageController>();

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => Get.offAll(() => const MainScreen()),
          child: const Text('Scheduled for Deletion'),
        ),
      ),
      body: Obx(() {
        final scheduledForLocalDeletion =
            imageController.scheduledForLocalDeletion;
        final scheduledForServerDeletion =
            imageController.scheduledForServerDeletion;

        if (scheduledForLocalDeletion.isEmpty &&
            scheduledForServerDeletion.isEmpty) {
          return const Center(
            child: Text('No images scheduled for deletion'),
          );
        } else {
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Scheduled for Local Deletion',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...scheduledForLocalDeletion.map((image) => ListTile(
                    leading: Image.file(image.file, fit: BoxFit.cover),
                    title: const Text('Scheduled for local deletion'),
                    subtitle: Text(image.createdAt.toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        imageController.cancelDeletion(image as ScreenshotInfo);
                      },
                    ),
                  )),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Deleted from Local, Scheduled for Server Deletion',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...scheduledForServerDeletion.map((image) => ListTile(
                    leading: Stack(
                      children: [
                        Image.file(image.file, fit: BoxFit.cover),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Icon(
                            Icons.download,
                            color: Colors.white.withOpacity(0.7),
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                    title: const Text('Deleted from local storage'),
                    subtitle: Text(image.createdAt.toString()),
                  )),
            ],
          );
        }
      }),
    );
  }
}
