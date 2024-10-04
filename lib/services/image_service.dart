import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageService {
  static const String baseUrl = 'http://localhost:5000';

  Future<Map<String, dynamic>> uploadImages(List<String> imagePaths) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

    for (var imagePath in imagePaths) {
      request.files.add(await http.MultipartFile.fromPath('images', imagePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload images');
    }
  }

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

  Future<Map<String, double>> getNimaScores(List<String> imagePaths) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/get_nima_score'));

    for (var imagePath in imagePaths) {
      request.files.add(await http.MultipartFile.fromPath('images', imagePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Map<String, double>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get NIMA scores');
    }
  }
}
