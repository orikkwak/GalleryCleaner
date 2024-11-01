import 'dart:io';
import 'package:get/get.dart';
import 'package:getlery_client/bindings/category_bindings.dart';
import 'package:getlery_client/bindings/category_detail_bindings.dart';
import 'package:getlery_client/bindings/delete_bindings.dart';
import 'package:getlery_client/bindings/group_bindings.dart';
import 'package:getlery_client/bindings/image_bindings.dart';
import 'package:getlery_client/bindings/main_screen_bindings.dart';
import 'package:getlery_client/bindings/set_bindings.dart';
import 'package:getlery_client/controllers/category_controller.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';
import 'package:getlery_client/controllers/set_controller.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/models/image_model.dart';
import 'package:getlery_client/views/category_detail_screen.dart';
import 'package:getlery_client/views/category_screen.dart';
import 'package:getlery_client/views/delete_scheduled_images_screen.dart';
import 'package:getlery_client/views/main_screen.dart';
import 'package:getlery_client/views/one_image_screen.dart';
import 'package:getlery_client/views/setting_screen.dart';
import 'package:getlery_client/views/group_viewer_screen.dart';
import 'package:getlery_client/widgets/grids/group_grid.dart';
import 'package:getlery_client/widgets/grids/zoomable_image_grid.dart';
import 'package:getlery_client/widgets/sort_option_bottom_sheet.dart';
import 'package:getlery_client/widgets/navigation_bar_widget.dart';
import 'package:getlery_client/widgets/delete_dialog.dart';
import 'package:getlery_client/widgets/image_loader.dart';

final List<GetPage> appRoutes = [
  // 메인 스크린 (앱 시작화면)
  GetPage(
    name: '/',
    page: () => MainScreen(),
    binding: MainScreenBinding(),
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
    binding: ImageBindings(),
  ),

  // 설정 화면
  GetPage(
    name: '/settings',
    page: () => const SettingScreen(),
    binding: SetBindings(),
  ),

  // 그룹 뷰어 스크린
  GetPage(
    name: '/group',
    page: () {
      final GroupModel group = Get.arguments['group'] as GroupModel;
      return GroupViewerScreen(group: group);
    },
    binding: GroupBindings(),
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
    binding: CategoryBinding(),
  ),

  // 특정 카테고리의 상세 화면
  GetPage(
    name: '/categoryDetail',
    page: () {
      final category = Get.arguments['category'] as Category;
      return CategoryDetailScreen(category: category);
    },
    binding: CategoryDetailBinding(), // 새로운 바인딩 추가
  ),

  // 삭제 예정 이미지 화면
  GetPage(
    name: '/deleteScheduledImages',
    page: () => const ScheduledImagesScreen(),
    binding: DeleteScheduledImagesBinding(),
  ),

  // 네비게이션 바 위젯 추가
  GetPage(
    name: '/navigationBar',
    page: () {
      final int currentPage = Get.arguments['currentPage'] as int;
      final dynamic Function(int) onPageSelected =
          Get.arguments['onPageSelected'] as dynamic Function(int);
      final bool hasCategories = Get.arguments['hasCategories'] as bool;
      final bool hasScheduledImages =
          Get.arguments['hasScheduledImages'] as bool;
      return NavigationBarWidget(
        currentPage: currentPage,
        onPageSelected: onPageSelected,
        hasCategories: hasCategories,
        hasScheduledImages: hasScheduledImages,
      );
    },
    binding: BindingsBuilder(() {
      Get.lazyPut(() => SetController());
    }),
  ),

  // 그룹 그리드 위젯 추가
  GetPage(
    name: '/groupGrid',
    page: () {
      Get.find<GroupController>();
      return GroupGrid();
    },
    binding: BindingsBuilder(() {
      Get.lazyPut(() => GroupController());
    }),
  ),

  // 줌 가능한 이미지 그리드 위젯 추가
  GetPage(
    name: '/zoomableImageGrid',
    page: () {
      final List<ImageModel> images =
          Get.arguments['images'] as List<ImageModel>;
      final bool showScheduledOnly =
          Get.arguments['showScheduledOnly'] as bool? ?? false;
      return ZoomableImageGrid(
        images: images,
        showScheduledOnly: showScheduledOnly,
      );
    },
    binding: BindingsBuilder(() {
      Get.lazyPut(() => ImageController());
    }),
  ),

  // 이미지 로더 위젯 추가
  GetPage(
    name: '/imageLoader',
    page: () {
      final Future<File?> imageFuture =
          Get.arguments['imageFuture'] as Future<File?>;
      return ImageLoader(imageFuture: imageFuture);
    },
    binding: BindingsBuilder(() {
      Get.lazyPut(() => ImageController());
    }),
  ),

  // 삭제 다이얼로그 위젯 추가
  GetPage(
    name: '/deleteDialog',
    page: () {
      final SelectionController selectionController =
          Get.arguments['selectionController'] as SelectionController;
      return DeleteDialog(selectionController: selectionController);
    },
    binding: BindingsBuilder(() {
      Get.lazyPut(() => SelectionController());
      Get.lazyPut(() => ImageController());
    }),
  ),
];
