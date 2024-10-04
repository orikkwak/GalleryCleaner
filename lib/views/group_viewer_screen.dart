// getlery/lib/views/group_viewer_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/models/group_model.dart';
import 'package:getlery/views/one_image_screen.dart';

class GroupViewerScreen extends StatefulWidget {
  final GroupModel group;

  GroupViewerScreen({required this.group});

  @override
  _GroupViewerScreenState createState() => _GroupViewerScreenState();
}

class _GroupViewerScreenState extends State<GroupViewerScreen> {
  int _crossAxisCount = 3; // 초기 그리드 열 개수
  double _scale = 1.0; // 현재 스케일 값

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group: ${widget.group.groupKey}'),
      ),
      body: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _scale = details.scale;
          });
          _updateCrossAxisCount(_scale);
        },
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: widget.group.images.length,
          itemBuilder: (context, index) {
            final image = widget.group.images[index];

            return GestureDetector(
              onTap: () => _navigateToOneImageScreen(context, index),
              child: FutureBuilder<File?>(
                future: image.file,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Image.file(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _updateCrossAxisCount(double scale) {
    setState(() {
      if (scale > 1.0 && _crossAxisCount > 1) {
        _crossAxisCount--;
      } else if (scale < 1.0 && _crossAxisCount < 6) {
        _crossAxisCount++;
      }
    });
  }

  void _navigateToOneImageScreen(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OneImageScreen(
          imageFileList: widget.group.images
              .map((img) => img.file)
              .whereType<File>()
              .toList(),
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}
