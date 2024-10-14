import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String baseUrl = 'http://localhost:3000';

  Future<void> loginUser(String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        body: jsonEncode({'deviceId': deviceId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        // 로그인 성공 후 사용자 정보 처리
        print('User logged in: ${userData['username']}');
      } else {
        print('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error logging in: $e');
    }
  }
}
