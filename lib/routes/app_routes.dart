import 'package:get/get.dart';
import 'package:getlery/views/one_image_screen.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'dart:io';

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
