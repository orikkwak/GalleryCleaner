// getlery/lib/services/image_upload_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUploadService {
  // 이미지를 서버로 업로드하는 메서드
  Future<http.Response> uploadImage(File image,
      {Function(int, int)? onSendProgress}) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://localhost:3000/photos')); // 서버 API URL

    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    // 진행 상태 확인용
    if (onSendProgress != null) {
      request.send().then((responseStream) {
        responseStream.stream.listen((value) {
          onSendProgress(value.length, request.contentLength ?? 0);
        });
      });
    }

    // 서버 응답을 받기 위해 실행
    var response = await request.send();
    return http.Response.fromStream(response);
  }

  // NIMA 점수를 서버에 전송하는 메서드
  Future<http.Response> sendNimaScore(String photoId, double nimaScore) async {
    var url = Uri.parse(
        'http://localhost:3000/nima/save_nima_score'); // NIMA 점수 전송 API
    var response = await http.post(
      url,
      body: {'photoId': photoId, 'nimaScore': nimaScore.toString()},
    );
    return response;
  }
}
