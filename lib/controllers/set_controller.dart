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

  Rx<AppThemeMode> themeMode = AppThemeMode.light.obs;
  Rx<Language> selectedLanguage = Language.english.obs;
  RxBool isAutoDelete = false.obs;
  RxInt autoDeleteHours = 22.obs; // 기본 삭제 시간 설정
  RxInt autoDeleteMinutes = 0.obs;
  RxBool isPushNotificationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings(); // 설정을 로드하면서 컨트롤러 초기화
  }

  Future<void> loadSettings() async {
    // Dark Mode 설정 불러오기
    themeMode.value = await settingsService.getThemeMode();
    selectedLanguage.value = await settingsService.getLanguage();
    isAutoDelete.value = await settingsService.getAutoDeleteStatus();
    isPushNotificationEnabled.value =
        await settingsService.getPushNotificationStatus();

    final cleanupInterval = await settingsService.getCleanupInterval();
    autoDeleteHours.value = cleanupInterval.inHours;
  }

// 자동 삭제 시간 및 분 설정 업데이트
  void setAutoDeleteHour(int hour, [int minutes = 0]) {
    autoDeleteHours.value = hour;
    autoDeleteMinutes.value = minutes;
    settingsService.setCleanupInterval(hour, minutes);
    updateAutoDeleteSchedule(); // 변경된 시간에 맞춰 스케줄 업데이트
  }

  // 자동 삭제 스케줄 설정
  void updateAutoDeleteSchedule() {
    screenshotManager.updateCheckHour(
      autoDeleteHours.value,
      autoDeleteMinutes.value,
    );
  }

  void toggleAutoDelete() {
    isAutoDelete.value = !isAutoDelete.value;
    settingsService.setAutoDeleteStatus(isAutoDelete.value);
    if (isAutoDelete.value) {
      screenshotManager.updateCheckHour(
          autoDeleteHours.value, autoDeleteMinutes.value);
    } else {
      screenshotManager.stopMonitoring();
    }
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode as AppThemeMode;
    settingsService.setThemeMode(mode as AppThemeMode);
    Get.changeThemeMode(
        mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light);
  }

  void setLanguage(Language language) {
    selectedLanguage.value = language;
    settingsService.setLanguage(language);
    Get.updateLocale(Locale(language == Language.korean ? 'ko' : 'en'));
  }

  void togglePushNotification() {
    isPushNotificationEnabled.value = !isPushNotificationEnabled.value;
    settingsService.setPushNotificationStatus(isPushNotificationEnabled.value);
  }
}
