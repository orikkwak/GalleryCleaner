// 파일 위치: lib/bindings/set_bindings.dart

import 'package:get/get.dart';
import 'package:getlery/controllers/set_controller.dart';

class SetBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(SetController()); // Set 컨트롤러 주입
  }
}
