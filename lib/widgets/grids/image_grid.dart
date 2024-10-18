// 파일 위치: lib/widgets/grids/image_grid.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getlery/widgets/image_loader.dart';

class ZoomableImageGrid extends StatefulWidget {
  final List<Future<File?>> images;
  final void Function(int) onTap;

  const ZoomableImageGrid({
    super.key,
    required this.images,
    required this.onTap,
  });

  @override
  ZoomableImageGridState createState() => ZoomableImageGridState();
}

class ZoomableImageGridState extends State<ZoomableImageGrid> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  int _crossAxisCount = 3;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        _previousScale = _scale;
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        setState(() {
          _scale = (_previousScale * details.scale).clamp(1.0, 3.0);
          _crossAxisCount = (3 / _scale).round().clamp(1, 5);
        });
      },
      child: GridView.builder(
        key: const ValueKey("ZoomableImageGrid"),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _crossAxisCount,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => widget.onTap(index),
            child: ImageLoader(
              key: ValueKey('image_grid_item_$index'), // A: 고유한 Key 추가로 오류 방지
              imageFuture: widget.images[index],
            ),
          );
        },
      ),
    );
  }
}
