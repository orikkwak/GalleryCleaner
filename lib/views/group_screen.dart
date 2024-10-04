// getlery/lib/views/group_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/controllers/group_controller.dart';
import 'package:getlery/models/group_model.dart';
import 'package:getlery/views/group_viewer_screen.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final GroupController _groupController = Get.find<GroupController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Images'),
      ),
      body: Obx(
        () {
          if (_groupController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final groupedImages = _groupController.minuteGroups;

          return CustomScrollView(
            slivers: [
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final group = groupedImages[index];

                    return GestureDetector(
                      onTap: () => _navigateToGroupViewer(group),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FutureBuilder<Uint8List?>(
                              future: group.representativeImage?.thumbnailData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Container();
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              child: Center(
                                child: Text(
                                  '${group.groupKey.month}/${group.groupKey.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
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
                  childCount: groupedImages.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToGroupViewer(GroupModel group) {
    Get.to(() => GroupViewerScreen(group: group));
  }
}
