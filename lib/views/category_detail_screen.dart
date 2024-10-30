// 파일 위치: lib/views/category_viewer_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/widgets/delete_dialog.dart';
import 'package:getlery_client/widgets/grids/zoomable_image_grid.dart';
import 'package:photo_view/photo_view.dart';

class CategoryViewerScreen extends StatelessWidget {
  final Category category;
  const CategoryViewerScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${category.name} 카테고리'),
        // actions: [
        //   DeleteDialog(
        //     onConfirm: () {
        //       // 카테고리를 삭제할 경우에 수행할 작업
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          _buildRepresentativeImage(),
          const SizedBox(height: 16),
          // Expanded(
          //   // child: ZoomableImageGrid(
          //   //   images:
          //   //       category.imageUrls.map((imageUrl) => File(imageUrl)).toList(),
          //   // ),
          // ),
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
