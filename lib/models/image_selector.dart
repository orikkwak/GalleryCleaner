import 'package:image/image.dart' as img;
import 'package:getlery/models/image_model.dart';
import 'dart:math' as math;

class ImageSelector {
  static Future<ImageModel> selectRepresentativeImage(
      List<ImageModel> images) async {
    ImageModel? representativeImage;
    double minVariance = double.infinity;

    for (final image in images) {
      final thumbnailData = await image.thumbnailData;
      if (thumbnailData != null) {
        final imageDecoded =
            img.decodeImage(thumbnailData.buffer.asUint8List());
        if (imageDecoded != null) {
          final variance = _calculatePixelVariance(imageDecoded);
          if (variance < minVariance) {
            minVariance = variance;
            representativeImage = image;
          }
        }
      }
    }

    return representativeImage ?? images.first;
  }

  static double _calculatePixelVariance(img.Image image) {
    final pixels = image.getBytes();
    int sumR = 0, sumG = 0, sumB = 0;
    int count = 0;

    for (int i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      sumR += r;
      sumG += g;
      sumB += b;
      count++;
    }

    final avgR = sumR / count;
    final avgG = sumG / count;
    final avgB = sumB / count;

    double varR = 0, varG = 0, varB = 0;

    for (int i = 0; i < pixels.length; i += 4) {
      final r = pixels[i];
      final g = pixels[i + 1];
      final b = pixels[i + 2];
      varR += math.pow(r - avgR, 2);
      varG += math.pow(g - avgG, 2);
      varB += math.pow(b - avgB, 2);
    }

    final variance = (varR + varG + varB) / (3 * count);
    return variance;
  }
}
