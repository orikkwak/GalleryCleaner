// 파일 위치: lib/utils/screenshot_manager.dart

import 'dart:async';
import 'dart:io';
import 'package:getlery_client/models/screenshot_model.dart';
import 'package:getlery_client/services/settings_service.dart';
import 'package:getlery_client/utils/notification_helper.dart';
import 'package:path_provider/path_provider.dart';

class ScreenshotManager {
  final List<ScreenshotInfo> _screenshotList = [];
  Timer? _monitoringTimer;
  final SettingsService settingsService;
  final NotificationHelper notificationHelper;

  ScreenshotManager({
    required this.settingsService,
    required this.notificationHelper,
  });

  // 스크린샷 폴더 경로 가져오기
  Future<Directory?> getScreenshotFolder() async {
    final directory = await getExternalStorageDirectory();
    return directory != null
        ? Directory('${directory.path}/Pictures/Screenshots')
        : null;
  }

  void stopMonitoring() {
    _monitoringTimer?.cancel();
  }

  // 매일 지정된 시간에 체크하는 스케줄 설정// 매일 지정된 시간과 분에 체크하는 스케줄 설정
  void updateCheckHour(int hour, int minute) {
    stopMonitoring(); // 기존 타이머 취소
    final now = DateTime.now();
    final nextCheck = DateTime(now.year, now.month, now.day, hour, minute);
    final durationUntilNextCheck = nextCheck.isAfter(now)
        ? nextCheck.difference(now)
        : nextCheck.add(const Duration(days: 1)).difference(now);

    _monitoringTimer = Timer(durationUntilNextCheck, () async {
      await _checkScreenshots();
      updateCheckHour(hour, minute); // 하루 뒤 다시 체크
    });
  }

  // 스크린샷 폴더에서 새 스크린샷 체크
  Future<void> _checkScreenshots() async {
    final screenshotFolder = await getScreenshotFolder();
    final screenshotFiles = screenshotFolder
        ?.listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.png'))
        .toList();

    for (var file in screenshotFiles!) {
      if (!_screenshotList
          .any((screenshot) => screenshot.filePath == file.path)) {
        // 새 스크린샷 발견 시 리스트에 추가
        _screenshotList.add(
            ScreenshotInfo(filePath: file.path, createdAt: DateTime.now()));
      }
    }
  }

// 스크린샷 추가 및 삭제 전 알림 예약
  Future<void> addScreenshot(ScreenshotInfo screenshotInfo) async {
    _screenshotList.add(screenshotInfo);

    // 삭제 1시간 전 알림 예약
    final autoDeleteDuration = await settingsService.getCleanupInterval();
    _scheduleDeletionWarning(
        screenshotInfo, autoDeleteDuration - const Duration(hours: 1));
  }

  // 삭제 1시간 전 알림 설정
  void _scheduleDeletionWarning(ScreenshotInfo screenshot, Duration duration) {
    Future.delayed(duration, () {
      notificationHelper.showNotification(
        title: 'Scheduled Deletion Alert',
        body: 'Screenshots will be deleted in 1 hour.',
        isPushNotificationEnabled: true,
      );
    });
  }
}
