// 파일 위치: lib/services/settings_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // 스크린샷 삭제 주기 불러오기 (시간 및 분 단위)
  Future<Duration> getCleanupInterval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int hours = prefs.getInt('cleanup_interval_hours') ?? 24;
    int minutes = prefs.getInt('cleanup_interval_minutes') ?? 0;
    return Duration(hours: hours, minutes: minutes);
  }

  // 스크린샷 삭제 주기 저장 (시간 및 분 단위)
  Future<void> setCleanupInterval(int hours, int minutes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cleanup_interval_hours', hours);
    await prefs.setInt('cleanup_interval_minutes', minutes);
  }

  // 새로운 메서드 추가: 자동 삭제 시간(시간 단위) 가져오기
  Future<int> getAutoDeleteHour() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('auto_delete_hour') ?? 22; // 기본 22시
  }

  // 새로운 메서드 추가: 자동 삭제 시간(시간 단위) 설정
  Future<void> setAutoDeleteHour(int hour) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('auto_delete_hour', hour);
  }
}
