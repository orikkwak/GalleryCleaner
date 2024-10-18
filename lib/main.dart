// 파일 위치: lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery/bindings/selection_binding.dart';
import 'package:getlery/bindings/set_bindings.dart';
import 'package:getlery/services/permission_service.dart';
import 'package:getlery/bindings/image_bindings.dart';
import 'package:getlery/bindings/group_bindings.dart'; // 그룹 바인딩 추가
import 'package:getlery/common/color_scheme.dart';
import 'package:getlery/common/translations_info.dart';
import 'package:getlery/controllers/group_controller.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'package:getlery/controllers/set_controller.dart';
import 'package:getlery/repositories/image_repository.dart';
import 'package:getlery/routes/app_routes.dart';

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
