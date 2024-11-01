// 파일 위치: lib/views/delete_scheduled_images_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/views/main_screen.dart';

class ScheduledImagesScreen extends StatefulWidget {
  const ScheduledImagesScreen({super.key});

  @override
  _ScheduledImagesScreenState createState() => _ScheduledImagesScreenState();
}

class _ScheduledImagesScreenState extends State<ScheduledImagesScreen> {
  final imageController = Get.find<ImageController>();
  final Set<ImageModel> selectedImages = Set<ImageModel>();

  @override
  Widget build(BuildContext context) {
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
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Scheduled for Local Deletion',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...scheduledForLocalDeletion.map((image) => ListTile(
                          leading: Stack(
                            children: [
                              Image.file(image.file, fit: BoxFit.cover),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Checkbox(
                                  value: selectedImages.contains(image),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedImages.add(image);
                                      } else {
                                        selectedImages.remove(image);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          title: const Text('Scheduled for local deletion'),
                          subtitle: Text(image.createdAt.toString()),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () async {
                              await imageController.cancelDeletion(image);
                              setState(() {
                                selectedImages.remove(image);
                              });
                            },
                          ),
                        )),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Deleted from Local, Scheduled for Server Deletion',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...scheduledForServerDeletion.map((image) => ListTile(
                          leading: Stack(
                            children: [
                              Image.file(image.file, fit: BoxFit.cover),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.download,
                                    color: selectedImages.contains(image)
                                        ? Colors.blue
                                        : Colors.white.withOpacity(0.7),
                                    size: 48,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      if (selectedImages.contains(image)) {
                                        selectedImages.remove(image);
                                      } else {
                                        selectedImages.add(image);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          title: const Text('Deleted from local storage'),
                          subtitle: Text(image.createdAt.toString()),
                        )),
                  ],
                ),
              ),
              if (selectedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // 선택된 모든 이미지의 삭제 상태를 취소하거나 복구
                      for (var image in selectedImages) {
                        if (imageController.scheduledForLocalDeletion
                            .contains(image)) {
                          await imageController.cancelDeletion(image);
                        } else if (imageController.scheduledForServerDeletion
                            .contains(image)) {
                          await imageController
                              .restoreDeletedImagesFromServer();
                        }
                      }

                      // 적용 후 상태 업데이트 및 선택된 항목 초기화
                      setState(() {
                        selectedImages.clear();
                      });

                      Get.offAll(() => const MainScreen());
                    },
                    child: const Text('Apply Changes'),
                  ),
                ),
            ],
          );
        }
      }),
    );
  }
}
