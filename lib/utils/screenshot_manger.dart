// 파일 위치: lib/utils/screenshot_manager.dart

import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';
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

  // 매일 지정된 시간에 체크하는 스케줄 설정
  void updateCheckHour(int hour) {
    _monitoringTimer?.cancel(); // 기존 타이머 취소
    final now = DateTime.now(); // 새로운 확인 시간으로 모니터링 시작
    final nextCheck = DateTime(now.year, now.month, now.day, hour);
    final durationUntilNextCheck = nextCheck.isAfter(now)
        ? nextCheck.difference(now)
        : nextCheck.add(const Duration(days: 1)).difference(now);
    _monitoringTimer = Timer(durationUntilNextCheck, () async {
      // 다음 체크 시간에 스크린샷 확인 실행
      await _checkScreenshots();
      performAutoDelete(); // 지정된 시간에 도달하면 performAutoDelete 실행
      updateCheckHour(hour); // 하루 뒤 다시 체크
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

  // 스크린샷을 삭제하고 목록에서 제거
  void performAutoDelete() {
    if (_screenshotList.isNotEmpty) {
      for (var screenshot in List<ScreenshotInfo>.from(_screenshotList)) {
        deleteScreenshot(screenshot.file);
        Get.find<ImageController>()
            .updateImageDeletionStatus(screenshot.file as ScreenshotInfo, true);
        _screenshotList.remove(screenshot);
      }
      _screenshotList.clear(); // 삭제 완료 후 리스트 초기화
      notificationHelper.showNotification(
        title: 'File Cleanup',
        body: 'Scheduled screenshots have been deleted.',
        isPushNotificationEnabled: true,
      );
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

  // 개별 스크린샷 삭제
  void deleteScreenshot(File screenshotFile) {
    if (screenshotFile.existsSync()) {
      screenshotFile.deleteSync();
      print("Screenshot auto-deleted: ${screenshotFile.path}");
    }
  }

  // 개별 삭제 예정 취소 메서드
  void cancelDeletion(ScreenshotInfo screenshot) {
    _screenshotList.remove(screenshot);
    Get.find<ImageController>()
        .updateImageDeletionStatus(screenshot, false); // 뷰에서 업데이트 반영
  }
}
