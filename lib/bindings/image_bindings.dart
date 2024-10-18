// 파일 위치: lib/bindings/image_bindings.dart

import 'package:get/get.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'package:getlery/repositories/image_repository.dart';

class ImageBindings extends Bindings {
  @override
  void dependencies() {
    // A: 모든 컨트롤러와 서비스를 이곳에서 주입
    Get.put(ImageRepository()); // 이미지 저장소 주입
    Get.put(ImageController()); // 이미지 컨트롤러 주입
  }
}
