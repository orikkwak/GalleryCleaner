// lib/controllers/permission_manager.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  Future<bool> requestPermissions() async {
    // 권한 요청
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();

    // 카메라 권한이 허용되고, 사진 또는 스토리지 권한이 허용된 경우
    bool isGranted = statuses[Permission.camera]!.isGranted &&
        (statuses[Permission.photos]!.isGranted ||
            statuses[Permission.storage]!.isGranted);

    return isGranted;
  }

  static Future<bool> requestPermissionsOnStart() async {
    PermissionManager permissionManager = PermissionManager();
    return await permissionManager.requestPermissions();
  }
}
