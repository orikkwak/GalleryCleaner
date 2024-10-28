import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getlery_client/widgets/image_loader.dart';

class ZoomableImageGrid extends StatefulWidget {
  final List<Future<File?>> images;
  final void Function(int) onTap;
  final void Function(int)? onLongPress; // onLongPress 추가

  const ZoomableImageGrid({
    super.key,
    required this.images,
    required this.onTap,
    this.onLongPress, // onLongPress 매개변수 추가
  });

  @override
  ZoomableImageGridState createState() => ZoomableImageGridState();
}

class ZoomableImageGridState extends State<ZoomableImageGrid> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_scale * details.scale).clamp(1.0, 3.0);
        });
      },
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (3 / _scale).round().clamp(1, 5),
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => widget.onTap(index),
            onLongPress: widget.onLongPress != null
                ? () => widget.onLongPress!(index)
                : null, // onLongPress 콜백
            child: ImageLoader(imageFuture: widget.images[index]),
          );
        },
      ),
    );
  }
}
