import 'package:image/image.dart' as img;

/// Average normalized luminance of [image]: 0.0 (black) – 1.0 (white).
///
/// Sampled on a grid (every [sampleStride] pixels) rather than scanning
/// every pixel — plenty accurate for a coarse "too dark for manual review"
/// gate, and far cheaper on a ~1600px selfie.
double computeAverageBrightness(img.Image image, {int sampleStride = 4}) {
  if (image.width == 0 || image.height == 0) return 0;

  final stride = sampleStride < 1 ? 1 : sampleStride;
  var total = 0.0;
  var count = 0;
  for (var y = 0; y < image.height; y += stride) {
    for (var x = 0; x < image.width; x += stride) {
      total += image.getPixel(x, y).luminanceNormalized;
      count++;
    }
  }
  return count == 0 ? 0 : total / count;
}
