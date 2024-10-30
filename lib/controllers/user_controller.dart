import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:getlery_client/services/auth_service.dart';

class UserController extends GetxController {
  final AuthService _authService = AuthService();
  RxString userId = ''.obs;
  RxString username = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser(); // 사용자 정보 로드
  }

  // 로컬에 저장된 사용자 ID를 불러와 자동 로그인
  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');
    if (storedUserId != null) {
      userId.value = storedUserId;
      await fetchUserInfo(storedUserId);
    } else {
      await createUser();
    }
  }

  // 새로운 사용자 생성
  Future<void> createUser() async {
    String deviceId = await _getDeviceId(); // 기기 ID 가져오기 (기기별로 다르게 설정)
    final userData = await _authService.loginOrCreateUser(deviceId);
    userId.value = userData['_id'];
    username.value = userData['username'];
  }

  // 사용자 정보 불러오기
  Future<void> fetchUserInfo(String userId) async {
    final userInfo = await _authService.getUserInfo(userId);
    username.value = userInfo['username'];
  }

  // 닉네임 업데이트
  Future<void> updateUsername(String newUsername) async {
    final updatedUser =
        await _authService.updateUsername(userId.value, newUsername);
    username.value = updatedUser['username'];
  }

  // 기기 ID 가져오기 (임시로 UUID 생성)
  Future<String> _getDeviceId() async {
    // 기기 고유 ID를 가져오는 로직 구현 필요
    // 예: device_info_plus 패키지 사용
    return 'device-id-placeholder'; // 임시 ID
  }
}
