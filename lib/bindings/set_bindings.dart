// 파일 위치: lib/bindings/set_bindings.dart

import 'package:get/get.dart';
import 'package:getlery_client/controllers/set_controller.dart';
// import 'package:getlery_client/services/settings_service.dart';

class SetBindings extends Bindings {
  @override
  void dependencies() {
    // SettingsService를 주입
    // Get.lazyPut<SettingsService>(() => SettingsService());
    Get.lazyPut<SetController>(() => SetController());
  }
}
