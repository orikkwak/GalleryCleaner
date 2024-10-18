// 파일 위치: lib/services/image_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:getlery/models/image_model.dart';
import 'package:http/http.dart' as http;

class ImageService {
  final String serverUrl = 'http://localhost:3000';

  //페이징이랑 캐싱

  // 이미지 가져오기
  Future<List<ImageModel>> fetchImages(
      DateTime startDate, DateTime endDate) async {
    final response = await http
        .get(Uri.parse('$serverUrl/images?start=$startDate&end=$endDate'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ImageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch images');
    }
  }

  // 이미지 업로드
  Future<void> uploadImage(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$serverUrl/upload'));
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    await request.send();
  }

  // 선택된 이미지 삭제
  Future<void> deleteSelectedImages(List<ImageModel> images) async {
    for (var image in images) {
      await deleteImage(image.id);
    }
  }

  // 이미지 삭제
  Future<void> deleteImage(String imageId) async {
    await http.delete(Uri.parse('$serverUrl/images/$imageId'));
  }
}
