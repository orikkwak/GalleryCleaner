// 파일 위치: lib/views/category_viewer_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/widgets/grids/zoomable_image_grid.dart';
import 'package:photo_view/photo_view.dart';

class CategoryScreen extends StatelessWidget {
  final Category category;
  const CategoryScreen({super.key, required this.category});

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
        ],
      ),
    );
  }

  // 대표 이미지를 표시하는 위젯
  Widget _buildRepresentativeImage() {
    final representativeImage =
        category.imageUrls.isNotEmpty ? category.imageUrls[0] : null;
    return representativeImage != null
        ? PhotoView(
            imageProvider: FileImage(File(representativeImage)),
          )
        : const Center(child: Text('대표 이미지가 없습니다.'));
  }
}
