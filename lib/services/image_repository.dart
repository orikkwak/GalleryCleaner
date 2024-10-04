// getlery/lib/services/image_repository.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ImageRepository extends GetxService {
  Map<String, double> _cachedNimaScores = {}; // 캐싱된 NIMA 점수

  Future<void> saveNimaScoreToCache(String photoId, double score) async {
    _cachedNimaScores[photoId] = score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(photoId, score);
  }

  Future<double?> getCachedNimaScore(String photoId) async {
    if (_cachedNimaScores.containsKey(photoId)) {
      return _cachedNimaScores[photoId];
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(photoId);
  }

  // 서버에서 NIMA 점수 가져오기 (이미지 파일 리스트를 받음)
  Future<Map<String, double>> getNimaScore(List<File> images) async {
    Map<String, double> nimaScores = {};

    for (File image in images) {
      String photoId = image.path.split('/').last;
      double? cachedScore = await getCachedNimaScore(photoId);

      if (cachedScore != null) {
        nimaScores[photoId] = cachedScore; // 캐시된 점수 사용
      } else {
        // 서버에 NIMA 점수 요청 코드 (생략)
        // 서버 요청 후 점수 저장
        double serverScore = await requestNimaScoreFromServer(image);
        nimaScores[photoId] = serverScore;

        // 캐시에 점수 저장
        await saveNimaScoreToCache(photoId, serverScore);
      }
    }
    return nimaScores;
  }

  Future<double> requestNimaScoreFromServer(File image) async {
    // 서버에 HTTP 요청을 보내는 코드 (여기서는 임시로 점수 생성)
    return Future.delayed(const Duration(seconds: 1), () => 7.0); // 가상의 NIMA 점수
  }

  // 캐시된 이미지 리스트 반환
  Future<List<File>> getCachedImages() async {
    Directory cacheDir = await getTemporaryDirectory();
    return cacheDir.listSync().whereType<File>().toList();
  }
}
