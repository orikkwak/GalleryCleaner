import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/widgets/delete_dialog.dart';
import 'package:getlery_client/widgets/grids/zoomable_image_grid.dart';
import 'package:photo_view/photo_view.dart';

class GroupViewerScreen extends StatelessWidget {
  final GroupModel group;
  const GroupViewerScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final groupController = Get.find<GroupController>();
    final selectionController = Get.find<SelectionController>();

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
          Expanded(
            child: ZoomableImageGrid(
              images:
                  group.images.map((imageModel) => imageModel.file).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepresentativeImage() {
    final representative = group.representativeImage;
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
            return PhotoView(imageProvider: FileImage(snapshot.data!));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _showFullImage(BuildContext context, Future<File?> imageFileFuture) {
    Get.to(
      () => Scaffold(
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
    );
  }
}
