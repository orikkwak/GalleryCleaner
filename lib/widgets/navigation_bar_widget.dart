// 파일 위치: lib/widgets/navigation_bar_widget.dart

import 'package:flutter/material.dart';

class NavigationBarWidget extends StatelessWidget {
  final int currentPage;
  final Function(int) onPageChanged;
  final bool hasCategories;
  final bool hasScheduledImages;

  const NavigationBarWidget({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
    required this.hasCategories,
    required this.hasScheduledImages,
  });

  @override
  Widget build(BuildContext context) {
    List<String> labels = ['메인'];

    if (hasCategories) {
      labels.add('카테고리');
    }
    if (hasScheduledImages) {
      labels.add('삭제 예정');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(labels.length, (index) {
        return GestureDetector(
          onTap: () => onPageChanged(index),
          child: Text(
            labels[index],
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  index == currentPage ? FontWeight.bold : FontWeight.normal,
              color: index == currentPage ? Colors.black : Colors.black54,
            ),
          ),
        );
      }),
    );
  }
}
