import 'dart:io';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/category_controller.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';
import 'package:getlery_client/controllers/set_controller.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/views/category_detail_screen.dart';
import 'package:getlery_client/views/category_screen.dart';
import 'package:getlery_client/views/main_screen.dart';
import 'package:getlery_client/views/one_image_screen.dart';
import 'package:getlery_client/views/setting_screen.dart';
import 'package:getlery_client/views/group_viewer_screen.dart';
import 'package:getlery_client/widgets/sort_option_bottom_sheet.dart';

final List<GetPage> appRoutes = [
  // 메인 스크린 (앱 시작화면)
  GetPage(
    name: '/',
    page: () => MainScreen(),
    binding: BindingsBuilder(() {
      Get.lazyPut(() => ImageController());
      Get.lazyPut(() => GroupController());
      Get.lazyPut(() => SelectionController());
    }),
  ),

  // 단일 이미지 뷰어 스크린
  GetPage(
    name: '/image',
    page: () {
      final List<File> imageFileList =
          Get.arguments['imageFileList'] as List<File>;
      final int initialIndex = Get.arguments['initialIndex'] as int;

      return OneImageScreen(
        imageFileList: imageFileList,
        initialIndex: initialIndex,
      );
    },
    binding: BindingsBuilder(() {
      Get.lazyPut(() => ImageController());
      Get.lazyPut(() => SelectionController());
    }),
  ),

  // 설정 화면
  GetPage(
    name: '/settings',
    page: () => SettingScreen(),
    binding: BindingsBuilder(() {
      Get.lazyPut(() => SetController());
    }),
  ),

  // 그룹 뷰어 스크린
  GetPage(
    name: '/group',
    page: () {
      final GroupModel group = Get.arguments['group'] as GroupModel;
      return GroupViewerScreen(group: group);
    },
    binding: BindingsBuilder(() {
      Get.lazyPut(() => GroupController());
      Get.lazyPut(() => SelectionController());
    }),
  ),

  // 정렬 옵션 바텀 시트
  GetPage(
    name: '/sortOptions',
    page: () {
      final ImageController imageController =
          Get.arguments['imageController'] as ImageController;
      final GroupController groupController =
          Get.arguments['groupController'] as GroupController;

      return SortOptionBottomSheet(
        imageController: imageController,
        groupController: groupController,
      );
    },
    binding: BindingsBuilder(() {
      Get.lazyPut(() => ImageController());
      Get.lazyPut(() => GroupController());
    }),
  ),

// 전체 카테고리를 표시하는 카테고리 목록 화면
  GetPage(
    name: '/categories',
    page: () =>
        CategoryScreen(categories: Get.find<CategoryController>().categories),
    binding: BindingsBuilder(() {
      Get.lazyPut(() => CategoryController());
    }),
  ),

  // 특정 카테고리의 상세 화면
  GetPage(
    name: '/categoryDetail',
    page: () {
      final category = Get.arguments['category'] as Category;
      return CategoryDetailScreen(category: category);
    },
    binding: BindingsBuilder(() {
      Get.lazyPut<CategoryController>(() => CategoryController());
    }),
  ),
];
