import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ImageService {
  final String baseUrl = 'http://localhost:3000';
  final String _nimaCacheKey = 'cached_nima_scores';

  // 이미지 업로드 API 호출 및 NIMA 점수 수신
  Future<Map<String, double>> uploadImages(List<String> imagePaths) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

    for (var imagePath in imagePaths) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final nimaScores = Map<String, double>.from(responseData['nimaScores']);
      return nimaScores;
    } else {
      throw Exception('Failed to upload images and get NIMA scores');
    }
  }

  // NIMA 점수 캐시에서 삭제
  Future<void> deleteNimaScoreFromCache(String imageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, double> cachedNimaScores =
        await _loadNimaScoresFromCache(prefs);
    cachedNimaScores.remove(imageId);
    prefs.setString(_nimaCacheKey, jsonEncode(cachedNimaScores));
  }

  // NIMA 점수 캐시에 저장
  Future<void> cacheNimaScore(String imageId, double nimaScore) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, double> cachedNimaScores =
        await _loadNimaScoresFromCache(prefs);
    cachedNimaScores[imageId] = nimaScore;
    prefs.setString(_nimaCacheKey, jsonEncode(cachedNimaScores));
  }

  // NIMA 점수 캐시에서 로드
  Future<Map<String, double>> _loadNimaScoresFromCache(
      SharedPreferences prefs) async {
    String? cachedData = prefs.getString(_nimaCacheKey);
    if (cachedData == null) return {};
    Map<String, dynamic> cachedScoresJson = jsonDecode(cachedData);
    return Map<String, double>.from(cachedScoresJson);
  }

  // 서버에서 이미지 가져오기
  Future<List<dynamic>> fetchImagesFromServer() async {
    final response = await http.get(Uri.parse('$baseUrl/images'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch images from server');
    }
  }

  // 이미지 삭제 API 호출
  Future<void> deleteImage(String imageId) async {
    final url = Uri.parse('$baseUrl/delete');
    final response = await http.delete(
      url,
      body: jsonEncode({'imageId': imageId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete image');
    }
  }
}
