import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../data/tux_assets.dart';

class TuxImageCache {
  TuxImageCache._();
  static final Map<String, ui.Image> _cache = <String, ui.Image>{};

  static ui.Image? get(String assetPath) => _cache[assetPath];

  static Future<ui.Image> load(String assetPath) async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath]!;
    }
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    _cache[assetPath] = frame.image;
    return frame.image;
  }

  static Future<void> preloadAllBrushes() async {
    final futures = <Future<ui.Image>>[];
    for (final brush in TuxAssets.brushes) {
      if (!_cache.containsKey(brush.assetPath)) {
        futures.add(load(brush.assetPath));
      }
    }
    await Future.wait(futures);
  }

  static void preloadAll(List<String> assetPaths) {
    for (final path in assetPaths) {
      load(path);
    }
  }
}
