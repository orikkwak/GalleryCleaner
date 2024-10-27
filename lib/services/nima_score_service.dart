// 파일 위치: lib/services/nima_score_service.dart

import 'dart:convert';
import 'package:getlery_client/models/image_model.dart';
import 'package:http/http.dart' as http;
import 'package:getlery_client/utils/network_helper.dart';

class NimaScoreService {
  final NetworkHelper _networkHelper = NetworkHelper();

  // NIMA 점수 업데이트
  Future<void> updateNimaScores(List<ImageModel> images) async {
    // 서버 연결 상태 확인
    if (!await _networkHelper.isServerConnected()) {
      print("Server not connected. Skipping NIMA score update.");
      return;
    }

    // 서버 연결된 경우에만 NIMA 점수 업데이트 실행
    for (var image in images) {
      final nimaScore = await _fetchNimaScoreFromFlask(image);
      if (nimaScore != null) {
        await _saveNimaScoreToNode(image.id, nimaScore);
      }
    }
  }

  // Flask 서버에서 NIMA 점수 가져오기
  Future<double?> _fetchNimaScoreFromFlask(ImageModel image) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(_networkHelper.flaskApiUrl));
    request.files
        .add(await http.MultipartFile.fromPath('image', image.filePath));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
      return jsonResponse['nima_scores'][image.id] as double;
    } else {
      print('Failed to get NIMA score');
      return null;
    }
  }

  // Node.js 서버로 NIMA 점수 저장
  Future<void> _saveNimaScoreToNode(String photoId, double nimaScore) async {
    try {
      final response = await http.post(
        Uri.parse(_networkHelper.nodeApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'photoId': photoId, 'nimaScore': nimaScore}),
      );

      if (response.statusCode == 200) {
        print('NIMA score successfully saved');
      } else {
        print('Failed to save NIMA score');
      }
    } catch (e) {
      print('Error saving NIMA score: $e');
    }
  }
}
