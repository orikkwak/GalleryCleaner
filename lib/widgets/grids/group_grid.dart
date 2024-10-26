// 파일 위치: lib/widgets/grids/group_grid.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/views/group_screen.dart';

class GroupGrid extends StatefulWidget {
  const GroupGrid({super.key});
  @override
  GroupGridState createState() => GroupGridState();
}

class GroupGridState extends State<GroupGrid> {
  final GroupController _groupController = Get.find<GroupController>();
  bool _isNavigating = false;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_groupController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final groupedPhotos = _groupController.groups;

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
            onTap: () =>
                _navigateToGroupViewerScreen(context, groupedPhotos[index]),
          );
        },
      );
    });
  }

  void _navigateToGroupViewerScreen(BuildContext context, GroupModel group) {
    if (Get.currentRoute != '/group_viewer') {
      if (!_isNavigating) {
        _isNavigating = true;
        Get.to(() => GroupViewerScreen(group: group))?.then((_) {
          _isNavigating = false; // 네비게이션 완료 후 다시 false로 설정
        });
      }
    }
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
                  return const Center(child: CircularProgressIndicator());
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
