import 'dart:io';
import 'package:getlery_client/utils/network_helper.dart';
import 'package:http/http.dart' as http;

class ImageRepository {
  final NetworkHelper _networkHelper = NetworkHelper();

  // 서버로 이미지 업로드
  Future<void> uploadImageToServer(File imageFile) async {
    if (await _networkHelper.isServerConnected()) {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${_networkHelper.serverUrl}/upload'));
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Failed to upload image to server');
      }
    } else {
      throw Exception('Server not connected');
    }
  }

  // 서버에서 이미지 삭제
  Future<void> deleteImageFromServer(String imageId) async {
    if (await _networkHelper.isServerConnected()) {
      final response = await http
          .delete(Uri.parse('${_networkHelper.serverUrl}/images/$imageId'));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete image from server');
      }
    } else {
      throw Exception('Server not connected');
    }
  }
}
