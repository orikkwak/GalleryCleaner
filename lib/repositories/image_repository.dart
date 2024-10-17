// getlery/lib/repositories/image_repository.dart

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:getlery/models/image_model.dart';
import 'package:http/http.dart' as http;

class ImageRepository {
  final String _cacheKey = 'cached_images';
  final String _serverUrl = 'http://localhost:3000';
  static const int _pageSize = 100; // 페이징 로드에 사용할 이미지 수

  // 페이징 로드 적용: 캐시에서 이미지 불러오기
  Future<List<ImageModel>> loadImagesFromCache(int pageIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString(_cacheKey);

    if (cachedData == null) return [];

    List<dynamic> cachedImagesJson = jsonDecode(cachedData);
    List<ImageModel> cachedImages =
        cachedImagesJson.map((json) => ImageModel.fromJson(json)).toList();

    // 페이징 로드 (페이지에 해당하는 이미지만 불러오기)
    int startIndex = pageIndex * _pageSize;
    int endIndex = startIndex + _pageSize;
    return cachedImages.sublist(
        startIndex, endIndex.clamp(0, cachedImages.length));
  }

  // 페이징 로드 적용: 서버에서 이미지 가져오기
  Future<List<ImageModel>> fetchImagesFromServer(
      int pageIndex, DateTime value) async {
    try {
      final response = await http.get(
          Uri.parse('$_serverUrl/images?page=$pageIndex&pageSize=$_pageSize'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ImageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load images from server');
      }
    } catch (e) {
      print("Error fetching images from server: $e");
      return [];
    }
  }

  // 이미지 업로드
  Future<void> uploadImage(File imageFile) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$_serverUrl/upload'));
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  // 이미지 삭제
  Future<void> deleteImage(String imageId) async {
    try {
      final response =
          await http.delete(Uri.parse('$_serverUrl/images/$imageId'));

      if (response.statusCode == 200) {
        print('Image deleted successfully');
      } else {
        throw Exception('Failed to delete image');
      }
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  // 캐시에 이미지 저장 (페이징 지원)
  Future<void> saveImagesToCache(List<ImageModel> images, int pageIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> imagesJson =
        images.map((image) => image.toJson()).toList();

    // 기존 캐시 데이터를 불러와 업데이트
    String? cachedData = prefs.getString(_cacheKey);
    List<dynamic> cachedImagesJson =
        cachedData != null ? jsonDecode(cachedData) : [];
    List<ImageModel> cachedImages =
        cachedImagesJson.map((json) => ImageModel.fromJson(json)).toList();

    int startIndex = pageIndex * _pageSize;
    for (int i = 0; i < images.length; i++) {
      if (startIndex + i < cachedImages.length) {
        cachedImages[startIndex + i] = images[i]; // 기존 데이터를 교체
      } else {
        cachedImages.add(images[i]); // 새 데이터 추가
      }
    }

    prefs.setString(_cacheKey, jsonEncode(cachedImages));
  }
}
