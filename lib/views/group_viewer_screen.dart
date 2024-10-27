// 파일 위치: lib/views/group_viewer_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';
import 'package:getlery_client/main.dart';
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/widgets/grids/image_grid.dart';
import 'package:getlery_client/widgets/delete_dialog.dart';
import 'package:photo_view/photo_view.dart';

// groupViewerScreen 전용 Navigator 키 추가
final GlobalKey<NavigatorState> groupViewerNavigatorKey =
    GlobalKey<NavigatorState>();

class GroupViewerScreen extends StatefulWidget {
  final GroupModel group;

  const GroupViewerScreen({super.key, required this.group});

  @override
  GroupViewerScreenState createState() => GroupViewerScreenState();
}

class GroupViewerScreenState extends State<GroupViewerScreen> {
  final GroupController groupController = Get.find<GroupController>();
  final SelectionController selectionController =
      Get.find<SelectionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Groups (${groupController.groups.length})')),
        actions: [
          DeleteDialog(selectionController: selectionController),
        ],
      ),
      body: Column(
        children: [
          _buildRepresentativeImage(),
          const SizedBox(height: 16),
          Expanded(child: _buildRemainingImages()), // 줌 가능한 그리드로 대체
        ],
      ),
    );
  }

  Widget _buildRepresentativeImage() {
    final representative = widget.group.representativeImage;
    if (representative == null) {
      return const Center(child: Text('No representative image available'));
    }
    return AspectRatio(
      aspectRatio: (representative.assetEntity.width /
              representative.assetEntity.height) ??
          1.0,
      child: FutureBuilder<File?>(
        future: representative.file,
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
    return ZoomableImageGrid(
      key: UniqueKey(),
      images: widget.group.images.map((imageModel) => imageModel.file).toList(),
      onTap: (index) =>
          _showFullImage(context, widget.group.images[index].file),
    );
  }

  void _showFullImage(BuildContext context, Future<File?> imageFileFuture) {
    MyApp.mainNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: FutureBuilder<File?>(
            future: imageFileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return PhotoView(
                  imageProvider: FileImage(snapshot.data!),
                  minScale: PhotoViewComputedScale.contained * 0.5,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
