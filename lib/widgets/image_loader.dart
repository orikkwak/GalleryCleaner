// 파일 위치: lib/widgets/image_loader.dart

import 'dart:io';
import 'package:flutter/material.dart';

class ImageLoader extends StatelessWidget {
  final Future<File?> imageFuture;

  const ImageLoader({super.key, required this.imageFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      key: UniqueKey(), // 고유한 키 추가
      future: imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image.file(snapshot.data!, fit: BoxFit.cover);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
