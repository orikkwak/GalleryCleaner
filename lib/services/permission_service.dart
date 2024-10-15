import 'package:permission_handler/permission_handler.dart';
import 'dart:io'; // 앱 종료를 위해 사용

class PermissionService {
  // 권한을 요청하는 메서드
  static Future<bool> requestPermissionsOnStart() async {
    // 필요한 권한들을 리스트로 나열
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage, // 저장소 접근 (안드로이드 12 이하)
      Permission.photos, // 미디어 접근 (안드로이드 13 이상)
      Permission.notification // 알림 권한
    ].request();

    bool isStorageGranted = statuses[Permission.storage]!.isGranted;
    bool isPhotosGranted = statuses[Permission.photos]!.isGranted;

    // 저장소 또는 사진 권한 중 하나라도 승인되지 않으면 false 반환
    if (!isStorageGranted && !isPhotosGranted) {
      print("저장소 또는 사진 권한이 허용되지 않았습니다.");
      exit(0); // 권한이 없으면 앱 종료
    }

    // 알림 권한은 필수가 아니므로 승인 여부에 상관없이 계속 진행
    if (statuses[Permission.notification]!.isGranted) {
      print("알림 권한이 승인되었습니다.");
    } else {
      print("알림 권한이 거부되었지만 필수는 아닙니다.");
    }

    return true; // 필수 권한이 승인된 경우
  }
}
