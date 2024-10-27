// 파일 위치: lib/utils/network_helper.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkHelper {
  static final NetworkHelper _instance = NetworkHelper._internal();
  factory NetworkHelper() => _instance;
  NetworkHelper._internal();

  // 서버 기본 URL 설정
  final String _serverUrl = 'http://localhost:3000';
  final String _flaskApiEndpoint = 'http://localhost:5000/get_nima_score';
  final String _nodeApiEndpoint = 'http://localhost:3000/nima/save_nima_score';
  final String _serverHealthCheckUrl = 'http://localhost:3000/health';

  // 서버 URL 접근을 위한 getter
  String get serverUrl => _serverUrl;

  // 네트워크 연결 상태 확인
  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  // 서버 연결 상태 확인
  Future<bool> isServerConnected() async {
    if (!await isConnected()) return false;

    try {
      final response = await http.get(Uri.parse(_serverHealthCheckUrl)).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception("Timeout"),
          );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Flask API URL 반환
  String get flaskApiUrl => _flaskApiEndpoint;

  // Node.js API URL 반환
  String get nodeApiUrl => _nodeApiEndpoint;
}
