// 파일 위치: lib/widgets/grids/group_grid.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/controllers/group_controller.dart';
import 'package:getlery/models/group_model.dart';
import 'package:getlery/views/group_viewer_screen.dart';

class GroupGrid extends StatelessWidget {
  final GroupController _groupController = Get.find<GroupController>();

  GroupGrid({super.key}); // const 제거

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_groupController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final groupedPhotos = _groupController.minuteGroups;

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
          final group = groupedPhotos[index];

          return GestureDetector(
            // key: UniqueKey(), // 고유한 키 추가
            onTap: () => _navigateToGroupViewerScreen(context, group),
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
                        return const CircularProgressIndicator();
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Center(
                      child: Text(
                        _getGroupName(group.groupKey),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void _navigateToGroupViewerScreen(BuildContext context, GroupModel group) {
    Get.to(() => GroupViewerScreen(group: group));
  }

  String _getGroupName(DateTime? groupKey) {
    if (groupKey == null) return '';
    return '${groupKey.month}월 ${groupKey.day}일 ${groupKey.hour}시 ${groupKey.minute}분';
  }
}
