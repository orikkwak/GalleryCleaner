// getlery/lib/views/photo_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewScreen extends StatelessWidget {
  final File photoFile;

  const PhotoViewScreen({Key? key, required this.photoFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo View"),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: FileImage(photoFile),
          backgroundDecoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
          ),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
