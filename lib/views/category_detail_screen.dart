import 'package:flutter/material.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/widgets/grids/zoomable_image_grid.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Category category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${category.name}  (${category.images.length})'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ZoomableImageGrid(
              images: category.images,
            ),
          ),
        ],
      ),
    );
  }
}
