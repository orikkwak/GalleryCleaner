// lib/widgets/sort_option_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'package:getlery/controllers/group_controller.dart';

class SortOptionBottomSheet extends StatelessWidget {
  final ImageController imageController;
  final GroupController groupController;

  const SortOptionBottomSheet({
    super.key,
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
          const Text('Sort By',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Newest First'),
            onTap: () {
              imageController.sortImages(true);
              groupController.sortGroups(true);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Oldest First'),
            onTap: () {
              imageController.sortImages(false);
              groupController.sortGroups(false);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
