import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'dart:io';

class ImageGridScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final imageController = Get.find<ImageController>();

    return Obx(() {
      if (imageController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return GridView.builder(
        itemCount: imageController.images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 그리드에 한 줄에 3개의 이미지 표시
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemBuilder: (context, index) {
          final image = imageController.images[index];
          return GestureDetector(
            onTap: () {
              imageController.handleTap(index);
            },
            child: FutureBuilder<File?>(
              future: image.file,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Image.file(snapshot.data!, fit: BoxFit.cover);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          );
        },
      );
    });
  }
}
