import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class SController extends GetxController {
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void onInit() async {
    super.onInit();
    final capturedImage = await screenshotController.capture();
    print(capturedImage); // 여기서 이미지 아이디값을 받아온다
    // 스크린샷 감지 시작
    startScreenshotDetection();
  }

  // 펑션 하나 만들고 걸러주기

  static const platform = MethodChannel('screenshot_detector');

  Future<void> startScreenshotDetection() async {
    try {
      await platform.invokeMethod('startScreenshotDetection');
      print("Screenshot detection started");
    } on PlatformException catch (e) {
      print("Failed to start screenshot detection: '${e.message}'.");
    }
  }

  void onScreenshotDetected() {
    print("Screenshot detected");
    // 30초 후에 알림을 표시
    Future.delayed(const Duration(seconds: 30), () {
      _showDeleteDialog(Get.context!);
    });
  }

  void _showDeleteDialog(BuildContext context) {
    print("Showing delete dialog");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('스크린샷 삭제'),
          content: const Text('스크린샷을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                // 스크린샷 파일 삭제 로직
                Navigator.of(context).pop();
                _deleteScreenshot();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteScreenshot() {
    // 스크린샷 파일 삭제 구현
    print("스크린샷 파일 삭제");
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final screenshotController = Get.put(SController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('스크린샷 감지기'),
        ),
        body: const Center(
          child: Text('스크린샷을 감지 중입니다...'),
        ),
      ),
    );
  }
}
