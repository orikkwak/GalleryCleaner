import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/widgets/grids/zoomable_image_grid.dart';
import 'package:photo_view/photo_view.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Category category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${category.name} 카테고리'),
      ),
      body: Column(
        children: [
          _buildRepresentativeImage(),
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

  // 대표 이미지 표시
  Widget _buildRepresentativeImage() {
    final latestImage = category.images.isNotEmpty
        ? category.images.last.filePath // ImageModel에서 filePath를 가져옴
        : null;

    return latestImage != null
        ? PhotoView(
            imageProvider: FileImage(File(latestImage)),
          )
        : const Center(child: Text('대표 이미지가 없습니다.'));
  }
}
