import 'dart:convert';
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
  final String _categoryApiEndpoint = 'http://localhost:3000/api/categories';

  String get categoryApiUrl => _categoryApiEndpoint;
  String get serverUrl => _serverUrl;
  String get flaskApiUrl => _flaskApiEndpoint;
  String get nodeApiUrl => _nodeApiEndpoint;

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

  // 공통 GET 요청 메서드
  Future<http.Response> getRequest(String endpoint) async {
    if (!await isConnected()) throw Exception("No internet connection");

    final url = Uri.parse('$_serverUrl/$endpoint');
    final response = await http.get(url).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception("Request timed out"),
        );

    if (response.statusCode != 200) {
      throw Exception("Failed GET request: ${response.statusCode}");
    }
    return response;
  }

  // 공통 POST 요청 메서드
  Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    if (!await isConnected()) throw Exception("No internet connection");

    final url = Uri.parse('$_serverUrl/$endpoint');
    final response = await http.post(
      url,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception("Request timed out"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed POST request: ${response.statusCode}");
    }
    return response;
  }

  // 공통 PUT 요청 메서드 추가
  Future<http.Response> putRequest(
      String endpoint, Map<String, dynamic> data) async {
    if (!await isConnected()) throw Exception("No internet connection");

    final url = Uri.parse('$_serverUrl/$endpoint');
    final response = await http.put(
      url,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception("Request timed out"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed PUT request: ${response.statusCode}");
    }
    return response;
  }
}
