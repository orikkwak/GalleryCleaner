// lib/services/photo_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo_model.dart';

class PhotoService {
  static Future<List<Photo>> fetchPhotos() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/photos'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }
}


// // getlery/lib/services/photo_service.dart
// import 'dart:io';
// import 'package:getlery/models/image_model.dart';

// class PhotoService {
//   Future<void> deletePhotos(List<Photo> photos) async {
//     for (Photo photo in photos) {
//       File? file = await photo.file;
//       if (file != null && await file.exists()) {
//         await file.delete();
//       }
//     }
//   }
// }
