import 'package:flutter/material.dart';
import 'xb_image_editor_opera.dart';

class XBImageEditorOperaPen extends XBImageEditorOpera {
  final List<Offset> points;
  final Color color;
  final double lineWidth;
  final double scale;

  XBImageEditorOperaPen(
      {required this.points,
      required this.color,
      required this.lineWidth,
      required this.scale});

  @override
  XBImageEditorOpera deepCopy() {
    return XBImageEditorOperaPen(
        points: points, color: color, lineWidth: lineWidth, scale: scale);
  }
}
