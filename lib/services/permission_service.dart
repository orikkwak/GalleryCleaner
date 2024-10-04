// getlery/lib/services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // 앱 시작 시 필요한 권한 요청 (사진 및 저장소)
  static Future<bool> requestPermissionsOnStart() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage, // 저장소 권한
      Permission.photos, // 사진 권한
    ].request();

    // 두 권한 모두 승인된 경우
    bool isGranted = statuses[Permission.storage]!.isGranted &&
        statuses[Permission.photos]!.isGranted;

    return isGranted;
  }

  // 저장소 권한 상태 확인 및 요청
  static Future<bool> checkStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      return await Permission.storage.request().isGranted;
    }
    return status.isGranted;
  }

  // 사진 권한 상태 확인 및 요청
  static Future<bool> checkPhotoPermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      return await Permission.photos.request().isGranted;
    }
    return status.isGranted;
  }
}
