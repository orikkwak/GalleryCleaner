import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class OneImageScreen extends StatefulWidget {
  final List<File> imageFileList;
  final int initialIndex;

  const OneImageScreen({
    super.key,
    required this.imageFileList,
    required this.initialIndex,
  });

  @override
  OneImageScreenState createState() => OneImageScreenState();
}

class OneImageScreenState extends State<OneImageScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Image ${_currentIndex + 1}/${widget.imageFileList.length}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // 세로로 아래로 스크롤 시 이전 페이지로 돌아가기
            Get.back();
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.imageFileList.length,
          scrollDirection: Axis.horizontal, // 가로 스크롤 설정
          itemBuilder: (context, index) {
            final imageFile = widget.imageFileList[index];

            return PhotoView(
              imageProvider: FileImage(imageFile),
              minScale: PhotoViewComputedScale.contained * 0.5,
              maxScale: PhotoViewComputedScale.covered * 2.0,
              initialScale: PhotoViewComputedScale.contained,
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.error),
              ),
            );
          },
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
