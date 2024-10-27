import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/views/group_viewer_screen.dart';

class GroupGrid extends StatelessWidget {
  const GroupGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupController groupController = Get.find<GroupController>();

    return Obx(() {
      if (groupController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final groupedPhotos = groupController.groups;

      return GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1.0,
        ),
        itemCount: groupedPhotos.length,
        itemBuilder: (BuildContext context, int index) {
          return GroupGridItem(
            group: groupedPhotos[index],
            onTap: () => Get.to(() => GroupViewerScreen(group: groupedPhotos[index])),
          );
        },
      );
    });
  }
}

class GroupGridItem extends StatelessWidget {
  final GroupModel group;
  final VoidCallback onTap;

  const GroupGridItem({
    super.key,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: FutureBuilder<File?>(
              future: group.representativeImage?.file,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Image.file(snapshot.data!, fit: BoxFit.cover);
                } else {
                  // 기본 배경색 추가
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Center(
                child: Text(
                  _getGroupName(group.groupKey),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGroupName(DateTime? groupKey) {
    if (groupKey == null) return '';
    return '${groupKey.month}월 ${groupKey.day}일 ${groupKey.hour}시 ${groupKey.minute}분';
  }
}
