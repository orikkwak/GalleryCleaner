// getlery/lib/views/widgets/photo_grid_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'package:getlery/views/one_image_screen.dart';

class PhotoGridScreen extends StatelessWidget {
  final ImageController _imageController = Get.find<ImageController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_imageController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 그리드 열 개수
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _imageController.images.length,
        itemBuilder: (context, index) {
          final image = _imageController.images[index];

          return GestureDetector(
            onTap: () => _navigateToOneImageScreen(context, index),
            child: Stack(
              children: [
                FutureBuilder<File?>(
                  future: image.file,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Image.file(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void _navigateToOneImageScreen(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OneImageScreen(
          imageFileList: _imageController.images
              .map((img) => img.file)
              .whereType<File>()
              .toList(),
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}
