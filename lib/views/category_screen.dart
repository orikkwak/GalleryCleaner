import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/category_controller.dart';
import 'package:getlery_client/views/category_detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  final CategoryController categoryController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('카테고리')),
      body: Obx(() {
        if (categoryController.categories.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            itemCount: categoryController.categories.length,
            itemBuilder: (context, index) {
              final category = categoryController.categories[index];
              return ListTile(
                title: Text(category.name),
                onTap: () => Get.to(CategoryDetailScreen(category: category)),
              );
            },
          );
        }
      }),
    );
  }
}
