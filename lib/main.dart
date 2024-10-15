// getlery/lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/services/permission_service.dart';
import 'package:getlery/bindings/image_bindings.dart';
import 'package:getlery/common/color_scheme.dart';
import 'package:getlery/common/translations_info.dart';
import 'package:getlery/controllers/group_controller.dart';
import 'package:getlery/controllers/image_controller.dart';
// import 'package:getlery/controllers/main_controller.dart';
import 'package:getlery/controllers/set_controller.dart';
import 'package:getlery/repositories/image_repository.dart';
import 'package:getlery/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 권한이 승인
  bool permissionGranted = await PermissionService.requestPermissionsOnStart();

  if (permissionGranted) {
    Get.put(ImageRepository()); // 서버와 통신 및 캐시 관리하는 ImageRepository
    Get.put(ImageController());
    // Get.put(MainController());
    Get.put(GroupController());
    Get.put(SetController());

    runApp(const MyApp());
  } else {
    // 권한 거부 시 처리
    print("필수 권한이 거부되었습니다. 앱이 종료됩니다.");
  }
}

// 앱 정상적으로 시작 시 실행되는 메인 앱
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      initialBinding: BindingsBuilder(() {
        ImageBindings().dependencies();
      }),
      getPages: appRoutes,
      defaultTransition: Transition.cupertino,
      translations: TranslationsInfo(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
        fontFamily: 'ChakraPetch',
      ),
      darkTheme: ThemeData(
        colorScheme: darkScheme,
        useMaterial3: true,
        fontFamily: 'ChakraPetch',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
