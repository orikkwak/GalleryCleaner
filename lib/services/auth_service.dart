import 'dart:convert';
import 'package:getlery_client/utils/network_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final NetworkHelper _networkHelper = NetworkHelper();

  // 사용자 자동 로그인 및 생성
  Future<Map<String, dynamic>> loginOrCreateUser(String deviceId) async {
    try {
      final response = await _networkHelper.postRequest(
        'user/login',
        {'deviceId': deviceId},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        // 로컬 저장소에 사용자 ID를 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userData['_id']);

        return userData;
      } else {
        throw Exception('Failed to login or create user');
      }
    } catch (e) {
      throw Exception('Error logging in or creating user: $e');
    }
  }

  // 사용자 정보 조회
  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    try {
      final response = await _networkHelper.getRequest('user/$userId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch user info');
      }
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }

  // 사용자 닉네임 업데이트
  Future<Map<String, dynamic>> updateUsername(
      String userId, String newUsername) async {
    try {
      final response = await _networkHelper.putRequest(
        'user/$userId',
        {'username': newUsername},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update username');
      }
    } catch (e) {
      throw Exception('Error updating username: $e');
    }
  }
}
