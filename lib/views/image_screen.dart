// getlery/lib/views/image_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'package:getlery/views/one_image_screen.dart';

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final ImageController _imageController = Get.find<ImageController>();
  final List<int> _selectedIndexes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Images'),
        actions: _selectedIndexes.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedImages,
                )
              ]
            : null,
      ),
      body: Obx(
        () {
          if (_imageController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: _imageController.images.length,
            itemBuilder: (context, index) {
              final image = _imageController.images[index];

              return GestureDetector(
                onLongPress: () => _toggleSelection(index),
                onTap: () => _handleImageTap(index),
                child: Stack(
                  children: [
                    FutureBuilder<File?>(
                      future: image.file,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.file(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                    if (_selectedIndexes.contains(index))
                      Positioned(
                        top: 8,
                        right: 8,
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  void _deleteSelectedImages() {
    // 삭제 로직 추가
    setState(() {
      for (var index in _selectedIndexes) {
        _imageController.images.removeAt(index);
      }
      _selectedIndexes.clear();
    });
  }

  void _handleImageTap(int index) {
    if (_selectedIndexes.isNotEmpty) {
      _toggleSelection(index);
    } else {
      // 단일 이미지로 이동
      _navigateToOneImageScreen(context, index);
    }
  }

  void _navigateToOneImageScreen(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OneImageScreen(
          imageFileList: _imageController.images
              .map((img) => img.file)
              .whereType<File>()
              .toList(),
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}
