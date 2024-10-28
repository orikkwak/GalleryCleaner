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
    return FutureBuilder<File?>(
      future: representative?.file,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return PhotoView(imageProvider: FileImage(snapshot.data!));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
