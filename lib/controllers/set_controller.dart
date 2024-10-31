// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getlery_client/services/settings_service.dart';
import 'package:getlery_client/utils/notification_helper.dart';
import 'package:getlery_client/utils/screenshot_manger.dart';

class SetController extends GetxController {
  final SettingsService settingsService = SettingsService();
  late NotificationHelper notificationHelper;
  late ScreenshotManager screenshotManager;

  RxBool isDarkMode = false.obs;
  RxString selectedLanguage = 'kr'.obs;
  RxBool isAutoDelete = false.obs;
  RxInt autoDeleteHours = 22.obs; // 기본 삭제 시간 설정
  RxInt autoDeleteMinutes = 0.obs;
  RxBool isPushNotificationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings(); // 설정을 로드하면서 컨트롤러 초기화
    screenshotManager = ScreenshotManager(
      settingsService: settingsService,
      notificationHelper: notificationHelper,
    );
  }

  Future<void> loadSettings() async {
    isDarkMode.value = Get.isDarkMode;
    selectedLanguage.value = Get.locale?.languageCode ?? 'en';
    // 자동 삭제 시간을 시간과 분 단위로 가져오기
    final cleanupInterval = await settingsService.getCleanupInterval();
    autoDeleteHours.value = cleanupInterval.inHours;
    autoDeleteMinutes.value = cleanupInterval.inMinutes.remainder(60);

    // 초기 설정된 시간에 스크린샷 모니터링 시작
    screenshotManager.updateCheckHour(autoDeleteHours.value);
  }

  void setAutoDeleteHour(int hour) {
    autoDeleteHours.value = hour;
    settingsService.setAutoDeleteHour(hour);
    screenshotManager.updateCheckHour(hour); // 변경된 시간으로 업데이트
  }

  void toggleAutoDelete() {
    isAutoDelete.value = !isAutoDelete.value;
    if (isAutoDelete.value) {
      screenshotManager.updateCheckHour;
    } else {
      screenshotManager.stopMonitoring();
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

  void togglePushNotification() {
    isPushNotificationEnabled.value = !isPushNotificationEnabled.value;
  }
}
