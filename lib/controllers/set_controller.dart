// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/models/screenshot_model.dart';
import 'package:getlery_client/utils/notification_helper.dart';
import 'package:getlery_client/utils/screenshot_manger.dart';

class SetController extends GetxController {
  final _screenshotList = <ScreenshotInfo>[].obs;
  List<ScreenshotInfo> get screenshotList => _screenshotList.toList();
  // static const platform = MethodChannel('screenshot_detector');

  RxBool isDarkMode = false.obs;
  RxString selectedLanguage = 'kr'.obs;
  RxBool isAutoDelete = false.obs;
  RxInt autoDeleteHours = 0.obs;
  RxInt autoDeleteMinutes = 0.obs;
  RxBool isPushNotificationEnabled = true.obs;

  late NotificationHelper notificationHelper;
  late ScreenshotManager screenshotManager;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = Get.isDarkMode;
    selectedLanguage.value = Get.locale?.languageCode ?? 'en';
    startAutoDeleteSchedule();
    // startScreenshotDetection();
  }

  // Future<void> startScreenshotDetection() async {
  //   try {
  //     await platform.invokeMethod('startScreenshotDetection');
  //     print("Screenshot detection started");
  //   } on PlatformException catch (e) {
  //     print("Failed to start screenshot detection: '${e.message}'.");
  //   }
  // }
// 자동 삭제 스케줄링 설정
  void startAutoDeleteSchedule() {
    final duration = Duration(
        hours: autoDeleteHours.value, minutes: autoDeleteMinutes.value);
    screenshotManager.startAutoDeleteSchedule(duration);
  }

  // 자동 삭제 알림
  void showAutoDeleteNotification() async {
    await notificationHelper.showNotification(
      title: 'File Cleanup',
      body: 'Scheduled screenshots have been deleted',
      isPushNotificationEnabled: isPushNotificationEnabled.value,
    );
  }

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void changeLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
    Get.updateLocale(Locale(languageCode));
  }

  void toggleAutoDelete() {
    isAutoDelete.value = !isAutoDelete.value;
  }

  void setAutoDeleteTime(int hours, int minutes) {
    autoDeleteHours.value = hours;
    autoDeleteMinutes.value = minutes;
  }

  void togglePushNotification() {
    isPushNotificationEnabled.value = !isPushNotificationEnabled.value;
  }

  void _showDeleteDialog(BuildContext context, ScreenshotInfo screenshotInfo) {
    showDialog(
      // context: context,
      context: Get.overlayContext!, // Get.context 대신 Get.overlayContext 사용
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('settings.deleteScreenshot'.tr),
          content: Text('settings.deleteScreenshotMessage'.tr),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr),
              onPressed: Get.back,
            ),
            TextButton(
              child: Text('delete'.tr),
              onPressed: () {
                _deleteScreenshot(screenshotInfo.file);
                _screenshotList.remove(screenshotInfo);
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteScreenshot(File screenshotFile) {
    print("Deleting screenshot: ${screenshotFile.path}");
    screenshotFile.delete();
  }

  void _scheduleAutoDelete(ScreenshotInfo screenshotInfo) {
    Future.delayed(
        Duration(
          hours: autoDeleteHours.value,
          minutes: autoDeleteMinutes.value,
        ), () {
      _deleteScreenshot(screenshotInfo.file);
      _screenshotList.remove(screenshotInfo);
      print("Screenshot auto-deleted: ${screenshotInfo.file.path}");
    });
  }
}
