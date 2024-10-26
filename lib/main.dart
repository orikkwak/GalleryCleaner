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

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: Get.key,
      initialRoute: '/',
      initialBinding: BindingsBuilder(() {
        SelectionBinding(); // 초기 바인딩 등록
        ImageBindings().dependencies(); // 이미지 관련 의존성
        GroupBindings().dependencies(); // 그룹 관련 의존성
        SetBindings().dependencies();
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
