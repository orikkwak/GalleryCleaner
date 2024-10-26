// 파일 위치: lib/views/one_image_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
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
    _pageController = PageController(
        initialPage:
            widget.initialIndex); // A: 페이지 컨트롤러에 initialPage 설정 (최적화: 초기값 적용)
  }

  @override
  void dispose() {
    _pageController.dispose(); // A: dispose를 통해 리소스 정리 최적화
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PageView.builder(
        // key: UniqueKey(), // 고유한 키 추가
        controller: _pageController,
        itemCount: widget.imageFileList.length,
        itemBuilder: (context, index) {
          final imageFile = widget.imageFileList[index]; // A: 현재 페이지의 이미지를 로드

          return PhotoView(
            // A: PhotoView를 사용하여 이미지 확대/축소 기능 제공 (사용자 경험 강화)
            imageProvider: FileImage(imageFile),
            minScale: PhotoViewComputedScale.contained * 0.5, // A: 최소 스케일 설정
            maxScale: PhotoViewComputedScale.covered * 2.0, // A: 최대 스케일 설정
            initialScale: PhotoViewComputedScale.contained, // A: 초기 스케일 설정
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(), // A: 이미지 로딩 중일 때 진행 표시
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
    );
  }
}
