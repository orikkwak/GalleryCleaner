// getlery/lib/services/nima_score_service.dart

import 'package:getlery/models/image_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NimaScoreService {
  final String _serverUrl = 'http://localhost:3000';
  final String _nimaCacheKey = 'cached_nima_scores';

  // 서버에서 NIMA 점수를 계산한 후 캐시에 저장
  Future<void> updateNimaScores(List<ImageModel> images) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, double> cachedNimaScores = _loadCachedNimaScores(prefs);

    var request =
        http.MultipartRequest('POST', Uri.parse('$_serverUrl/get_nima_score'));

    for (var image in images) {
      var file = await image.assetEntity.file;
      if (file != null && !cachedNimaScores.containsKey(image.id)) {
        request.files
            .add(await http.MultipartFile.fromPath('images', file.path));
      }
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await http.Response.fromStream(response);
      final nimaScores =
          jsonDecode(responseBody.body)['nima_scores'] as Map<String, double>;

      for (var image in images) {
        if (nimaScores.containsKey(image.id)) {
          image.nimaScore = nimaScores[image.id];
          cachedNimaScores[image.id] = image.nimaScore!;
        }
      }

      _saveNimaScoresToCache(cachedNimaScores, prefs);
    } else {
      throw Exception('Failed to calculate NIMA scores');
    }
  }

  // 캐시에서 NIMA 점수 불러오기
  Map<String, double> _loadCachedNimaScores(SharedPreferences prefs) {
    String? cachedData = prefs.getString(_nimaCacheKey);
    if (cachedData == null) return {};

    Map<String, dynamic> cachedScoresJson = jsonDecode(cachedData);
    return cachedScoresJson
        .map((key, value) => MapEntry(key, value.toDouble()));
  }

  // 캐시에 NIMA 점수 저장
  void _saveNimaScoresToCache(
      Map<String, double> scores, SharedPreferences prefs) {
    prefs.setString(_nimaCacheKey, jsonEncode(scores));
  }

  // 캐시된 NIMA 점수를 불러와 이미지 모델에 적용
  Future<void> applyCachedNimaScores(List<ImageModel> images) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, double> cachedNimaScores = _loadCachedNimaScores(prefs);

    for (var image in images) {
      if (cachedNimaScores.containsKey(image.id)) {
        image.nimaScore = cachedNimaScores[image.id];
      }
    }
  }
}
