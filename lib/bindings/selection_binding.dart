// 파일 위치: lib/bindings/selection_binding.dart

import 'package:get/get.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';

class SelectionBinding extends Bindings {
  @override
  void dependencies() {
    // 컨트롤러들을 바인딩에 등록
    Get.put(ImageController());
    Get.put(GroupController());
    Get.put(SelectionController());
  }
}
