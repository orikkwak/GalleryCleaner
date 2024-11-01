// 파일 위치: lib/bindings/one_image_binding.dart

import 'package:get/get.dart';

class OneImageBinding extends Bindings {
  @override
  void dependencies() {
    // 현재 특별히 주입할 의존성이 없음.
    // 추후 필요시 Get.lazyPut(() => SomeController()); 같은 방식으로 추가할 수 있음.
  }
}
