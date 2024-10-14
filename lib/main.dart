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
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 권한 요청 수정
  bool permissionGranted = await PermissionService.requestPermissionsOnStart();

  if (permissionGranted) {
    // 권한이 승인된 경우 DI로 컨트롤러 및 리포지토리 추가
    Get.put(ImageRepository()); // 서버와 통신 및 캐시 관리하는 ImageRepository
    Get.put(ImageController());
    // Get.put(MainController());
    Get.put(GroupController());
    Get.put(SetController());

    runApp(const MyApp());
  } else {
    // 권한 거부 시 처리
    runApp(const PermissionDeniedApp());
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

// 권한이 거부된 경우 실행되는 앱
class PermissionDeniedApp extends StatelessWidget {
  const PermissionDeniedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('필수 권한이 거부되었습니다. 앱을 사용하기 위해 권한을 허용해주세요.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  openAppSettings(); // 앱 설정으로 이동하여 권한을 직접 허용하도록 유도
                },
                child: const Text('설정 열기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
