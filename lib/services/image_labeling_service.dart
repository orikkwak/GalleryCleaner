import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:getlery_client/models/image_model.dart';

class ImageLabelingService {
  Future<List<String>> labelImage(File imageFile) async {
    // Google ML Kit의 이미지 라벨링 모델 가져오기
    final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
    final ImageLabelerOptions options = ImageLabelerOptions();
    final ImageLabeler labeler = ImageLabeler(options: options);

    // 이미지 라벨 처리하기
    final List<ImageLabel> labels = await labeler.processImage(inputImage);

    // 결과 변환 후 반환
    final List<String> labelTexts = labels.map((label) => label.label).toList();

    // 라벨러 닫기 (메모리 해제)
    labeler.close();

    return labelTexts;
  }

  Future<void> labelAndSaveImages(List<ImageModel> images) async {
    for (var image in images) {
      final labels = await labelImage(File(image.filePath));
      // 라벨을 image 객체의 필드에 저장
      image.labels = labels;
    }
  }
}