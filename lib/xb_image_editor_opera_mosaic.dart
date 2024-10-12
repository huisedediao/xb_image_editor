import 'package:flutter/material.dart';
import 'xb_image_editor_opera.dart';

class XBImageEditorOperaMosaicPoint {
  final Color color;
  final Offset position;
  XBImageEditorOperaMosaicPoint({required this.color, required this.position});
}

class XBImageEditorOperaMosaic extends XBImageEditorOpera {
  final List<XBImageEditorOperaMosaicPoint> points;
  final double lineWidth;
  final double scale;

  XBImageEditorOperaMosaic(
      {required this.points, required this.lineWidth, required this.scale});

  @override
  XBImageEditorOpera deepCopy() {
    return XBImageEditorOperaMosaic(
        points: points, lineWidth: lineWidth, scale: scale);
  }
}
