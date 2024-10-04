// getlery/lib/views/widgets/sort_option_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'package:getlery/controllers/group_controller.dart';

class SortOptionBottomSheet extends StatelessWidget {
  final ImageController imageController;
  final GroupController groupController;

  SortOptionBottomSheet({
    required this.imageController,
    required this.groupController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sort By',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Newest First'),
            onTap: () {
              imageController.sortImages(true); // 최신순 정렬
              groupController.sortGroups(true); // 최신 그룹 정렬
              Navigator.pop(context); // 시트 닫기
            },
          ),
          ListTile(
            title: const Text('Oldest First'),
            onTap: () {
              imageController.sortImages(false); // 오래된 순 정렬
              groupController.sortGroups(false); // 오래된 그룹 정렬
              Navigator.pop(context); // 시트 닫기
            },
          ),
        ],
      ),
    );
  }
}
