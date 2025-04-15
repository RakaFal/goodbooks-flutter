import 'package:flutter/rendering.dart';

class PerformanceConfig {
  static void disableDebugOverlays() {
    debugPaintLayerBordersEnabled = false;
    debugRepaintRainbowEnabled = false;
  }
  
  static void optimizeForEmulator() {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
}