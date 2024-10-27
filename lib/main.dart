// 파일 위치: lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/bindings/group_bindings.dart';
import 'package:getlery_client/bindings/image_bindings.dart';
import 'package:getlery_client/bindings/selection_binding.dart';
import 'package:getlery_client/bindings/set_bindings.dart';
import 'package:getlery_client/common/color_scheme.dart';
import 'package:getlery_client/common/translations_info.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/controllers/set_controller.dart';
import 'package:getlery_client/repositories/image_repository.dart';
import 'package:getlery_client/routes/app_routes.dart';
import 'package:getlery_client/services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 권한이 승인
  bool permissionGranted = await PermissionService.requestPermissionsOnStart();

  if (permissionGranted) {
    Get.put(ImageRepository());
    Get.put(ImageController());
    Get.put(GroupController());
    Get.put(SetController());

    runApp(const MyApp());
  } else {
    print("필수 권한이 거부되었습니다. 앱이 종료됩니다.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 전역 네비게이터 키 (최상위 네비게이터에만 적용)
  static final GlobalKey<NavigatorState> mainNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: mainNavigatorKey, // 설정
      initialRoute: '/',
      initialBinding: BindingsBuilder(() {
        Get.put(SelectionBinding());
        Get.put(ImageBindings());
        Get.put(GroupBindings());
        Get.put(SetBindings());
      }),
      getPages: appRoutes,
      defaultTransition: Transition.cupertino,
      translations: TranslationsInfo(),
      locale: Get.deviceLocale ?? const Locale('en', 'US'),
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
