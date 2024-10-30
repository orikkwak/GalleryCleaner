import 'dart:io';
import 'package:getlery_client/utils/network_helper.dart';
import 'package:http/http.dart' as http;

class ImageRepository {
  final NetworkHelper _networkHelper = NetworkHelper();

// 서버에 중복 이미지 확인
  Future<bool> checkDuplicateImage(String imageId) async {
    final response = await http.get(
      Uri.parse('${_networkHelper.serverUrl}/images/exists/$imageId'),
    );
    return response.statusCode == 200;
  }

  // 서버로 이미지 업로드
  Future<void> uploadImageToServer(File imageFile) async {
    var request = http.MultipartRequest(
      'POST', Uri.parse('${_networkHelper.serverUrl}/upload'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload image to server');
    }
  }

  // 서버에서 삭제 일정을 설정
  Future<void> scheduleImageDeletion(String imageId) async {
    final response = await http.post(
      Uri.parse('${_networkHelper.serverUrl}/images/schedule-delete/$imageId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to schedule deletion for image on server');
    }
  }

  // 서버에서 이미지 삭제
  Future<void> deleteImageFromServer(String imageId) async {
    final response = await http.delete(
      Uri.parse('${_networkHelper.serverUrl}/images/$imageId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete image from server');
    }
  }
}
