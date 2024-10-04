// getlery/lib/models/image_similarity.dart
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';
import 'dart:math' as math;

class ImageSimilarity {
  static Future<double> comparePixels(
      AssetEntity image1, AssetEntity image2) async {
    final data1 =
        await image1.thumbnailDataWithSize(const ThumbnailSize(200, 200));
    final data2 =
        await image2.thumbnailDataWithSize(const ThumbnailSize(200, 200));
    if (data1 == null || data2 == null) {
      return 0.0;
    }

    final pixels1 = img.decodeImage(data1.buffer.asUint8List());
    final pixels2 = img.decodeImage(data2.buffer.asUint8List());

    if (pixels1 == null || pixels2 == null) {
      return 0.0;
    }

    final size1 = pixels1.width * pixels1.height;
    final size2 = pixels2.width * pixels2.height;

    var sumDiff = 0.0;
    for (var y = 0; y < pixels1.height; y++) {
      for (var x = 0; x < pixels1.width; x++) {
        final color1 = pixels1.getPixel(x, y);
        final color2 = pixels2.getPixel(x % pixels2.width, y % pixels2.height);
        final dr = (color1.r - color2.r).abs();
        final dg = (color1.g - color2.g).abs();
        final db = (color1.b - color2.b).abs();
        sumDiff += math.sqrt(dr * dr + dg * dg + db * db);
      }
    }

    final avgDiff = sumDiff / (math.sqrt(3) * math.max(size1, size2));
    return 1 - avgDiff / 255;
  }
}
