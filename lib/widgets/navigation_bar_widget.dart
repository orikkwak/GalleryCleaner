// 파일 위치: lib/widgets/navigation_bar_widget.dart

import 'package:flutter/material.dart';

class NavigationBarWidget extends StatelessWidget {
  final int currentPage;
  final Function(int) onPageSelected; // 콜백 함수
  final bool hasCategories;
  final bool hasScheduledImages;

  const NavigationBarWidget({
    Key? key,
    required this.currentPage,
    required this.onPageSelected,
    required this.hasCategories,
    required this.hasScheduledImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 네비게이션 라벨 설정
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
          onTap: () => onPageSelected(index), // 클릭 시 페이지 이동 콜백 호출
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
