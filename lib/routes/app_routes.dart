import 'dart:io';
import 'package:get/get.dart';
import 'package:getlery_client/bindings/category_bindings.dart';
import 'package:getlery_client/bindings/delete_dialog_bindings.dart';
import 'package:getlery_client/bindings/group_bindings.dart';
import 'package:getlery_client/bindings/group_grid_binding.dart';
import 'package:getlery_client/bindings/image_bindings.dart';
import 'package:getlery_client/bindings/main_content_bindings.dart';
import 'package:getlery_client/bindings/main_screen_bindings.dart';
import 'package:getlery_client/bindings/one_image_bindings.dart';
import 'package:getlery_client/bindings/scheduled_images_bindings.dart';
import 'package:getlery_client/bindings/set_bindings.dart';
import 'package:getlery_client/bindings/sort_option_bottom_sheet.dart';
import 'package:getlery_client/bindings/zoomable_image_grid_bindings.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/models/group_model.dart';
import 'package:getlery_client/views/category_detail_screen.dart';
import 'package:getlery_client/views/category_screen.dart';
import 'package:getlery_client/views/delete_scheduled_images_screen.dart';
import 'package:getlery_client/views/main_screen.dart';
import 'package:getlery_client/views/one_image_screen.dart';
import 'package:getlery_client/views/setting_screen.dart';
import 'package:getlery_client/views/group_viewer_screen.dart';
import 'package:getlery_client/widgets/grids/group_grid.dart';
import 'package:getlery_client/widgets/grids/zoomable_image_grid.dart';
import 'package:getlery_client/widgets/main_content.dart';
import 'package:getlery_client/widgets/sort_option_bottom_sheet.dart';
import 'package:getlery_client/widgets/delete_dialog.dart';
import 'package:getlery_client/widgets/image_loader.dart';

final List<GetPage> appRoutes = [
  // 메인 스크린 (앱 시작화면)
  GetPage(
    name: '/',
    page: () => const MainScreen(),
    binding: MainScreenBinding(), // 바인딩 추가
  ),

  // OneImageScreen 라우트 추가
  GetPage(
    name: '/oneImage',
    page: () {
      final List<File> imageFileList =
          Get.arguments['imageFileList'] as List<File>;
      final int initialIndex = Get.arguments['initialIndex'] as int;

      return OneImageScreen(
        imageFileList: imageFileList,
        initialIndex: initialIndex,
      );
    },
    binding: OneImageBinding(), // 바인딩 추가
  ),

  // SettingScreen 라우트 추가
  GetPage(
    name: '/settings',
    page: () => SettingScreen(),
    binding: SetBindings(), // 바인딩 추가
  ),

  // GroupViewerScreen 라우트 추가
  GetPage(
    name: '/groupViewer',
    page: () {
      final GroupModel group = Get.arguments['group'] as GroupModel;
      return GroupViewerScreen(group: group);
    },
    binding: GroupBindings(), // 바인딩 추가
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
    binding: SortOptionBinding(),
  ),

  // 카테고리 화면 라우트 추가
  GetPage(
    name: '/categories',
    page: () {
      final List<Category> categories =
          Get.arguments['categories'] as List<Category>;
      return CategoryScreen(categories: categories);
    },
    binding: CategoryBinding(),
  ),

  // 특정 카테고리 상세 화면 라우트 추가
  GetPage(
    name: '/categoryDetail',
    page: () {
      final Category category = Get.arguments['category'] as Category;
      return CategoryDetailScreen(category: category);
    },
  ),

  // 삭제 예정 이미지 화면 라우트 추가
  GetPage(
    name: '/deleteScheduledImages',
    page: () => const ScheduledImagesScreen(),
    binding: ScheduledImagesBinding(), // 바인딩 추가
  ),

  // 그룹 그리드 화면 추가
  GetPage(
    name: '/groupGrid',
    page: () => const GroupGrid(),
    binding: GroupGridBinding(),
  ),

  // 줌 가능한 이미지 그리드 화면 추가
  GetPage(
    name: '/zoomableImageGrid',
    page: () => ZoomableImageGrid(
      images: Get.arguments['images'],
      showScheduledOnly: Get.arguments['showScheduledOnly'] ?? false,
    ),
    binding: ZoomableImageGridBinding(),
  ),

  // 이미지 로더 화면 추가
  GetPage(
    name: '/imageLoader',
    page: () {
      final Future<File?> imageFuture =
          Get.arguments['imageFuture'] as Future<File?>;
      return ImageLoader(imageFuture: imageFuture);
    },
  ),

  // 삭제 다이얼로그 화면 추가
  GetPage(
    name: '/deleteDialog',
    page: () {
      final SelectionController selectionController =
          Get.find<SelectionController>();
      return DeleteDialog(selectionController: selectionController);
    },
    binding: DeleteDialogBinding(), // 바인딩 추가
  ),
  // MainContent 라우트 추가
  GetPage(
    name: '/mainContent',
    page: () => MainContent(imageController: Get.find<ImageController>()),
    binding: MainContentBinding(), // 바인딩 추가
  ),
  GetPage(
    name: '/scheduledImages',
    page: () => const ScheduledImagesScreen(),
    binding: BindingsBuilder(() {
      ImageBindings().dependencies(); // 필요한 바인딩 등록
    }),
  ),
];
