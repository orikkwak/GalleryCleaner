// 파일 위치: lib/services/nima_score_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:getlery/models/image_model.dart';
// import 'package:path/path.dart';

class NimaScoreService {
  final String flaskApiEndpoint = 'http://localhost:5000/get_nima_score';
  final String nodeApiEndpoint = 'http://localhost:3000/nima/save_nima_score';

  // NIMA 점수 업데이트
  Future<void> updateNimaScores(List<ImageModel> images) async {
    for (var image in images) {
      final nimaScore = await _fetchNimaScoreFromFlask(image);
      if (nimaScore != null) {
        await _saveNimaScoreToNode(image.id, nimaScore);
      }
    }
  }

  // Flask 서버에서 NIMA 점수 가져오기
  // Future<double?> _fetchNimaScoreFromFlask(ImageModel image) async {
  //   try {
  //     final request =
  //         http.MultipartRequest('POST', Uri.parse(flaskApiEndpoint));
  //     request.files
  //         .add(await http.MultipartFile.fromPath('images', image.filePath));
  //
  //     final response = await request.send();
  //     final responseData = await response.stream.bytesToString();
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
  //       return jsonResponse['nima_scores'][basename(image.filePath)] as double;
  //     } else {
  //       print('Failed to get NIMA score');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error fetching NIMA score: $e');
  //     return null;
  //   }
  // }

// Flask 서버에서 NIMA 점수 가져오기
  Future<double?> _fetchNimaScoreFromFlask(ImageModel image) async {
    var request = http.MultipartRequest('POST', Uri.parse(flaskApiEndpoint));
    request.files
        .add(await http.MultipartFile.fromPath('image', image.filePath));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
      return jsonResponse['nima_scores'][image.id] as double;
    } else {
      return null;
    }
  }

  // Node.js 서버로 NIMA 점수 저장
  Future<void> _saveNimaScoreToNode(String photoId, double nimaScore) async {
    try {
      final response = await http.post(
        Uri.parse(nodeApiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'photoId': photoId, 'nimaScore': nimaScore}),
      );

      if (response.statusCode == 200) {
        print('NIMA 점수 저장 성공');
      } else {
        print('Failed to save NIMA score');
      }
    } catch (e) {
      print('Error saving NIMA score: $e');
    }
  }
}
