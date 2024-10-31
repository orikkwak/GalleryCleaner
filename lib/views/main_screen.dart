import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/category_controller.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/utils/network_helper.dart';
import 'package:getlery_client/views/delete_scheduled_images_screen.dart';
import 'package:getlery_client/views/setting_screen.dart';
import 'package:getlery_client/views/category_screen.dart';
import 'package:getlery_client/widgets/navigation_bar_widget.dart';
import 'package:getlery_client/widgets/sort_option_bottom_sheet.dart';
import 'package:getlery_client/widgets/main_content.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isConnected = false;
  bool hasScheduledImages = false;

  @override
  void initState() {
    super.initState();
    initializeConnectionStatus();
  }

  Future<void> initializeConnectionStatus() async {
    isConnected = await NetworkHelper().isServerConnected();
    setState(() {});

    if (isConnected) {
      final imageController = Get.find<ImageController>();
      await imageController.loadScheduledImages();
      setState(() {}); // 상태 업데이트를 통해 `hasScheduledImages` 반영
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToPage(int page) {
    _pageController.jumpToPage(page);
    _onPageChanged(page);
  }

  @override
  Widget build(BuildContext context) {
    final imageController = Get.find<ImageController>();
    final groupController = Get.find<GroupController>();
    final categoryController = Get.find<CategoryController>();
    final hasCategories = isConnected;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (hasCategories || hasScheduledImages) // 네비게이션 바 표시 조건
              NavigationBarWidget(
                currentPage: _currentPage,
                onPageSelected: _navigateToPage, // 페이지 변경 함수
                hasCategories: hasCategories,
                hasScheduledImages: hasScheduledImages, // 오타 수정
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  MainContent(imageController: imageController),
                  if (hasCategories)
                    Obx(() => CategoryScreen(
                          categories: categoryController.categories,
                        )),
                  if (hasScheduledImages) const ScheduledImagesScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SortOptionBottomSheet(
              imageController: imageController,
              groupController: groupController,
            ),
          );
        },
        child: const Icon(Icons.more_vert, color: Colors.white),
      ),
    );
  }
}
