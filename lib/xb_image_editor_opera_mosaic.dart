import 'package:flutter/material.dart';
import 'xb_image_editor_opera.dart';

class XBImageEditorOperaMosaicPoint {
  final Color color;
  final Offset position;
  XBImageEditorOperaMosaicPoint({required this.color, required this.position});
}

class XBImageEditorOperaMosaic extends XBImageEditorOpera {
  final List<XBImageEditorOperaMosaicPoint> points;
  final Color color;
  final double lineWidth;
  final double scale;

  XBImageEditorOperaMosaic(
      {required this.points,
      required this.color,
      required this.lineWidth,
      required this.scale});

  @override
  XBImageEditorOpera deepCopy() {
    return XBImageEditorOperaMosaic(
        points: points, color: color, lineWidth: lineWidth, scale: scale);
  }
}
