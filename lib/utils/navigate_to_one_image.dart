// 파일 위치: lib/utils/navigate_to_one_image.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/views/one_image_screen.dart';
import 'dart:io';

void navigateToOneImageScreen(
    BuildContext context, List<File> images, int initialIndex) {
  Get.to(() => OneImageScreen(
        imageFileList: images,
        initialIndex: initialIndex,
      ));
}
