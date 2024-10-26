import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'dart:io';
import 'package:getlery_client/views/one_image_screen.dart';

final List<GetPage> appRoutes = [
  GetPage(
    name: '/image',
    page: () {
      final File photoFile = Get.arguments['photoFile'] as File;
      final int initialIndex = Get.arguments['initialIndex'] as int;

      return OneImageScreen(
        imageFileList: [photoFile],
        initialIndex: initialIndex,
      );
    },
    binding: BindingsBuilder(() {
      Get.lazyPut(() => ImageController());
    }),
  ),
];
