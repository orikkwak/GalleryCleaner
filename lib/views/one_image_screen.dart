//D:\getlery\lib\views\one_image_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class OneImageScreen extends StatefulWidget {
  final List<File> imageFileList;
  final int initialIndex;

  OneImageScreen({
    required this.imageFileList,
    required this.initialIndex,
  });

  @override
  _OneImageScreenState createState() => _OneImageScreenState();
}

class _OneImageScreenState extends State<OneImageScreen> {
  late PageController _pageController;
  late int _currentIndex;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
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
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 300),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.imageFileList.length,
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
              _triggerFadeEffect();
            });
          },
        ),
      ),
    );
  }

  void _triggerFadeEffect() {
    setState(() {
      _opacity = 0.0;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }
}
