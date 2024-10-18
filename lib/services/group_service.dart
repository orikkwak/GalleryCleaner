// 파일 위치: lib/services/group_service.dart
//니마대표이미지 어디서있는지

import 'dart:convert';
import 'package:getlery/models/group_model.dart';
import 'package:http/http.dart' as http;

class GroupService {
  final String serverUrl = 'http://localhost:3000';

  // 서버 연결 여부 확인 (ping 방식)
  Future<bool> isServerConnected() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/ping'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 서버에서 유사도 기반 그룹화된 이미지 가져오기
  Future<List<GroupModel>> fetchGroupsBySimilarity() async {
    final response =
        await http.get(Uri.parse('$serverUrl/groups/group-similarity'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GroupModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch similar grouped images');
    }
  }

  // 날짜 범위 기반 그룹 가져오기
  Future<List<GroupModel>> fetchGroupsByDate(
      DateTime startDate, DateTime endDate) async {
    final response = await http
        .get(Uri.parse('$serverUrl/groups?start=$startDate&end=$endDate'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GroupModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch groups by date');
    }
  }
}
