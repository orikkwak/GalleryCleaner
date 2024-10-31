// 파일 위치: lib/utils/screenshot_manager.dart

import 'dart:io';
import 'dart:async';
import 'package:getlery_client/models/screenshot_model.dart';

class ScreenshotManager {
  final List<ScreenshotInfo> _screenshotList = [];
  Timer? _autoDeleteTimer;

  // 스크린샷 목록을 반환
  List<ScreenshotInfo> get screenshotList => List.unmodifiable(_screenshotList);

  // 스크린샷 추가 및 자동 삭제 예약
  void addScreenshot(
      ScreenshotInfo screenshotInfo, Duration autoDeleteDuration) {
    _screenshotList.add(screenshotInfo);
    if (autoDeleteDuration.inSeconds > 0) {
      _scheduleAutoDelete(screenshotInfo, autoDeleteDuration);
    }
  }

  // 특정 시간마다 자동 삭제 스케줄링
  void startAutoDeleteSchedule(Duration duration) {
    _autoDeleteTimer?.cancel(); // 기존 타이머 취소
    if (duration.inSeconds > 0) {
      _autoDeleteTimer = Timer.periodic(duration, (timer) {
        performAutoDelete();
      });
    }
  }

  // 스크린샷을 삭제하고 목록에서 제거
  void performAutoDelete() {
    for (var screenshot in _screenshotList) {
      _deleteScreenshot(screenshot.file);
    }
    _screenshotList.clear(); // 삭제 완료 후 리스트 초기화
  }

  void _deleteScreenshot(File screenshotFile) {
    screenshotFile.deleteSync();
    print("Screenshot auto-deleted: ${screenshotFile.path}");
  }

  // 특정 스크린샷에 대한 자동 삭제 예약
  void _scheduleAutoDelete(ScreenshotInfo screenshotInfo, Duration duration) {
    Future.delayed(duration, () {
      _deleteScreenshot(screenshotInfo.file);
      _screenshotList.remove(screenshotInfo);
    });
  }

  void cancel() {
    _autoDeleteTimer?.cancel();
  }
}
