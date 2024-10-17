// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:getlery/models/screenshot_model.dart';

class SetController extends GetxController {
  final _screenshotList = <ScreenshotInfo>[].obs;
  List<ScreenshotInfo> get screenshotList => _screenshotList.toList();
  static const platform = MethodChannel('screenshot_detector');

  RxBool isDarkMode = false.obs;
  RxString selectedLanguage = 'kr'.obs;
  RxBool isAutoDelete = false.obs;
  RxInt autoDeleteHours = 0.obs;
  RxInt autoDeleteMinutes = 0.obs;
  RxBool isPushNotificationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = Get.isDarkMode;
    selectedLanguage.value = Get.locale?.languageCode ?? 'en';
    startScreenshotDetection();
  }

  Future<void> startScreenshotDetection() async {
    try {
      await platform.invokeMethod('startScreenshotDetection');
      print("Screenshot detection started");
    } on PlatformException catch (e) {
      print("Failed to start screenshot detection: '${e.message}'.");
    }
  }

  void onScreenshotDetected(ScreenshotInfo screenshotInfo) {
    print("Screenshot detected");
    if (isAutoDelete.value) {
      _scheduleAutoDelete(screenshotInfo);
    } else {
      _showDeleteDialog(Get.context!, screenshotInfo);
    }
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
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('settings.deleteScreenshot'.tr),
          content: Text('settings.deleteScreenshotMessage'.tr),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('delete'.tr),
              onPressed: () {
                _deleteScreenshot(screenshotInfo.file);
                _screenshotList.remove(screenshotInfo);
                Navigator.of(context).pop();
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
