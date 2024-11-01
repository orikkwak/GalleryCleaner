import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark } // 여기서 AppThemeMode로 이름 변경

enum Language { english, korean }

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

  // 자동 삭제 활성화 상태 불러오기
  Future<bool> getAutoDeleteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auto_delete_status') ?? false;
  }

  // 자동 삭제 활성화 상태 저장
  Future<void> setAutoDeleteStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_delete_status', status);
  }

  // 알림 설정 관련 메서드
  Future<bool> getPushNotificationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('push_notification_enabled') ?? true;
  }

  Future<void> setPushNotificationStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notification_enabled', status);
  }

  // 화면 모드 설정 관련 메서드
  Future<AppThemeMode> getThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String mode = prefs.getString('theme_mode') ?? 'light';
    return mode == 'dark' ? AppThemeMode.dark : AppThemeMode.light;
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'theme_mode', mode == AppThemeMode.dark ? 'dark' : 'light');
  }

  // 언어 설정 관련 메서드
  Future<Language> getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String language = prefs.getString('selected_language') ?? 'en';
    return language == 'ko' ? Language.korean : Language.english;
  }

  Future<void> setLanguage(Language language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'selected_language', language == Language.korean ? 'ko' : 'en');
  }
}
