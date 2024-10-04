import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';
import 'dart:math' as math;

class ImageSimilarity {
  // 이미지 픽셀 비교
  static Future<double> comparePixels(
      AssetEntity image1, AssetEntity image2) async {
    // 이미지 썸네일 불러오기
    final data1 =
        await image1.thumbnailDataWithSize(const ThumbnailSize(200, 200));
    final data2 =
        await image2.thumbnailDataWithSize(const ThumbnailSize(200, 200));

    if (data1 == null || data2 == null) {
      return 0.0;
    }

    // 이미지 디코딩
    final pixels1 = img.decodeImage(data1.buffer.asUint8List());
    final pixels2 = img.decodeImage(data2.buffer.asUint8List());

    if (pixels1 == null || pixels2 == null) {
      return 0.0;
    }

    // 이미지 크기 확인
    final size1 = pixels1.width * pixels1.height;
    final size2 = pixels2.width * pixels2.height;

    var sumDiff = 0.0;

    // 이미지 픽셀 비교
    for (var y = 0; y < pixels1.height; y++) {
      for (var x = 0; x < pixels1.width; x++) {
        // 픽셀 색상 값 추출
        final color1 = pixels1.getPixel(x, y);
        final color2 = pixels2.getPixel(x % pixels2.width, y % pixels2.height);

        // ARGB에서 각각 r, g, b 값 분리
        final r1 = (color1 >> 16) & 0xFF;
        final g1 = (color1 >> 8) & 0xFF;
        final b1 = color1 & 0xFF;

        final r2 = (color2 >> 16) & 0xFF;
        final g2 = (color2 >> 8) & 0xFF;
        final b2 = color2 & 0xFF;

        // 차이 계산
        final dr = (r1 - r2).abs();
        final dg = (g1 - g2).abs();
        final db = (b1 - b2).abs();

        // 유클리드 거리로 차이 누적
        sumDiff += math.sqrt(dr * dr + dg * dg + db * db);
      }
    }

    // 평균 차이 계산
    final avgDiff = sumDiff / (math.sqrt(3) * math.max(size1, size2));
    return 1 - avgDiff / 255;
  }
}
