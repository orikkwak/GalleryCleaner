// lib/views/group_viewer_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getlery/models/group_model.dart';
import 'package:photo_view/photo_view.dart';

class GroupViewerScreen extends StatelessWidget {
  final GroupModel group;

  GroupViewerScreen({required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group: ${group.groupKey}'),
      ),
      body: Column(
        children: [
          // 대표 이미지
          _buildRepresentativeImage(),
          const SizedBox(height: 16),
          // 나머지 이미지들
          Expanded(child: _buildRemainingImages()),
        ],
      ),
    );
  }

  Widget _buildRepresentativeImage() {
    return Container(
      width: double.infinity,
      height: 300, // 대표 이미지 크기
      child: FutureBuilder<File?>(
        future: group.representativeImage?.file,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return PhotoView(
              imageProvider: FileImage(snapshot.data!),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildRemainingImages() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 한 줄에 3개씩
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: group.images.length,
      itemBuilder: (context, index) {
        final image = group.images[index];

        return FutureBuilder<File?>(
          future: image.file,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return GestureDetector(
                onTap: () => _showFullImage(context, snapshot.data!),
                child: Image.file(
                  snapshot.data!,
                  fit: BoxFit.cover,
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        );
      },
    );
  }

  void _showFullImage(BuildContext context, File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: PhotoView(
            imageProvider: FileImage(imageFile),
            minScale: PhotoViewComputedScale.contained * 0.5,
            maxScale: PhotoViewComputedScale.covered * 2.0,
          ),
        ),
      ),
    );
  }
}
