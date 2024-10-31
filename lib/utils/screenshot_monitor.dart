import 'dart:async';
import 'dart:io';
import 'package:getlery_client/models/screenshot_model.dart';
import 'package:getlery_client/utils/screenshot_manger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ScreenshotMonitor {
  final ScreenshotManager screenshotManager;
  final List<String> _knownScreenshots = [];
  int checkHour; // 사용자가 선택한 체크 시간 (24시간 형식)
  ScreenshotMonitor({required this.screenshotManager, this.checkHour = 22});

  // 사용자가 설정한 시간에 하루에 한 번 폴더를 확인하는 타이머 설정
  void _scheduleDailyCheck() {
    final now = DateTime.now();
    final nextCheck = DateTime(now.year, now.month, now.day, checkHour);
    final durationUntilNextCheck = nextCheck.isAfter(now)
        ? nextCheck.difference(now)
        : nextCheck.add(Duration(days: 1)).difference(now);

    Timer(durationUntilNextCheck, () async {
      await _checkForNewScreenshots();
      _scheduleDailyCheck(); // 다음 날 동일한 시간에 다시 체크
    });
  }

  // 스크린샷 폴더에서 새 스크린샷 체크
  Future<void> _checkForNewScreenshots() async {
    final screenshotFolder = await _getScreenshotFolder();
    final screenshotFiles = screenshotFolder!
        .listSync()
        .whereType<File>()
        .where((file) => path.extension(file.path).toLowerCase() == '.png')
        .toList();

    for (var file in screenshotFiles) {
      if (!_knownScreenshots.contains(file.path)) {
        _knownScreenshots.add(file.path);
        final screenshotInfo = ScreenshotInfo(
          filePath: file.path,
          createdAt: DateTime.now(),
        );
        await screenshotManager.addScreenshot(screenshotInfo);
      }
    }
  }

  // 안드로이드 스크린샷 폴더 경로 가져오기
  Future<Directory?> _getScreenshotFolder() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        // "Pictures/Screenshots" 폴더 경로 반환
        return Directory('${directory.path}/Pictures/Screenshots');
      }
    } catch (e) {
      print("Error getting screenshot folder: $e");
    }
    return null;
  }
}
