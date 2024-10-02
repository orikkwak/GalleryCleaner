// lib/views/photo_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/photo_controller.dart';

class PhotoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PhotoController controller = Get.find();

    return Scaffold(
      appBar: AppBar(title: Text('Photos')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: controller.photos.length,
            itemBuilder: (context, index) {
              final photo = controller.photos[index];
              return ListTile(
                title: Text(photo.title),
                subtitle: Text(photo.description),
                leading: Image.network(photo.imageUrl),
              );
            },
          );
        }
      }),
    );
  }
}
