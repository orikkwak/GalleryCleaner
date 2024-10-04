// getlery/lib/views/photo_view.dart
import 'dart:io';
import 'package:flutter/material.dart';

class PhotoViewScreen extends StatelessWidget {
  final File photoFile;

  const PhotoViewScreen({Key? key, required this.photoFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo View'),
      ),
      body: PhotoView(
        imageProvider: FileImage(photoFile),
        minScale: PhotoViewComputedScale.contained * 0.5,
        maxScale: PhotoViewComputedScale.covered * 2.0,
      ),
    );
  }
}
