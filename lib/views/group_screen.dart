// 파일 위치: lib/views/group_viewer_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/controllers/group_controller.dart';
import 'package:getlery/controllers/selection_controller.dart';
import 'package:getlery/models/group_model.dart';
import 'package:getlery/widgets/delete_dialog.dart';
import 'package:getlery/widgets/grids/image_grid.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';

class GroupViewerScreen extends StatelessWidget {
  final GroupModel group;

  const GroupViewerScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find<GroupController>();
    final SelectionController selectionController =
        Get.find<SelectionController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Groups (${groupController.groups.length})')),
        actions: [
          // 삭제 다이얼로그 추가
          DeleteDialog(selectionController: selectionController),
        ],
      ),
      body: Column(
        children: [
          _buildRepresentativeImage(), // 대표 이미지 크게 표시
          const SizedBox(height: 16),
          Expanded(child: _buildRemainingImages()), // 나머지 이미지를 그리드로 표시
        ],
      ),
    );
  }

  // 대표 이미지를 원본 비율로 크게 표시
  Widget _buildRepresentativeImage() {
    return AspectRatio(
      aspectRatio: group.representativeImage?.assetEntity.width.toDouble() ??
          1 / (group.representativeImage?.assetEntity.height.toDouble() ?? 1),
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

  // 나머지 이미지들을 조절 가능한 그리드로 표시
  Widget _buildRemainingImages() {
    return ZoomableImageGrid(
      // 이미지 줌인/줌아웃 기능이 있는 그리드 사용
      images: group.images.map((img) => img.file).toList(), // 이미지 리스트 전달
      onTap: (index) => _showFullImage(context as BuildContext,
          group.images[index].file! as File), // 이미지 선택 시 전체 화면 표시
    );
  }

  // 선택된 이미지 전체 화면으로 표시
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
