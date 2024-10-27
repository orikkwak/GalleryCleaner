import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getlery_client/widgets/image_loader.dart';

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
            child: ImageLoader(imageFuture: widget.images[index]),
          );
        },
      ),
    );
  }
}
