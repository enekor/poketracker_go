// lib/core/utils/image_utils.dart

import 'package:flutter/material.dart';

class ImageUtils {
  /// ColorFilter for greyscale + reduced opacity (not owned Pokémon).
  static ColorFilter greyscaleFilter(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final opacity = brightness == Brightness.dark ? 0.4 : 0.5;

    // Greyscale color matrix
    return ColorFilter.matrix(<double>[
      0.2126 * opacity, 0.7152 * opacity, 0.0722 * opacity, 0, 0,
      0.2126 * opacity, 0.7152 * opacity, 0.0722 * opacity, 0, 0,
      0.2126 * opacity, 0.7152 * opacity, 0.0722 * opacity, 0, 0,
      0, 0, 0, opacity, 0,
    ]);
  }
}
