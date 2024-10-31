// 파일 위치: lib/services/settings_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  Future<Duration> getCleanupInterval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int hours = prefs.getInt('cleanup_interval') ?? 24; // 기본 24시간 (1일) 설정
    return Duration(hours: hours);
  }

  Future<void> setCleanupInterval(int hours) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cleanup_interval', hours);
  }
}
