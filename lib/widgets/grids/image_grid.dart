// 파일 위치: lib/widgets/grids/image_grid.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getlery/widgets/image_loader.dart';

class ImageGrid extends StatelessWidget {
  final List<Future<File?>> images;
  final int crossAxisCount;
  final void Function(int) onTap;

  const ImageGrid({
    super.key,
    required this.images,
    this.crossAxisCount = 3,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          key: UniqueKey(), // 고유한 키 추가
          onTap: () => onTap(index),
          child: ImageLoader(imageFuture: images[index]),
        );
      },
    );
  }
}
