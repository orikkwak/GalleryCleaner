// 파일 위치: lib/services/image_labeling_service.dart

import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:getlery_client/models/image_model.dart';

class ImageLabelingService {
  Future<List<String?>> labelImage(File imageFile) async {
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();

    final List<ImageLabel> labels = await labeler.processImage(visionImage);
    return labels.map((label) => label.text).toList();
  }

  Future<void> labelAndSaveImages(List<ImageModel> images) async {
    for (var image in images) {
      final labels = await labelImage(File(image.filePath));
      // 라벨을 image 객체의 필드에 저장
      image.labels = labels.cast<String>();
    }
  }
}
