import 'dart:math';
import 'package:flutter/material.dart';
import 'xb_image_editor_funs.dart';
import 'xb_image_editor_opera.dart';
import 'package:vector_math/vector_math_64.dart' as math64;

class XBImageEditorOperaText extends XBImageEditorOpera {
  String text;
  final Color color;
  double fontSize;
  final double scale;
  double angle;
  Offset position;
  bool isSelected;

  /// 触摸在文本区域
  bool isTaping;

  /// 触摸在编辑区域
  bool isTapingEdit;

  final double xSize;
  final double xGap;
  final double editSize;
  final double editGap;
  final double lineWidth;

  Size get getTextSize => textSize(text, TextStyle(fontSize: fontSize * scale));

  bool isInArea(Offset point) {
    final size = getTextSize;
    return point.dx >= position.dx &&
        point.dx <= position.dx + size.width &&
        point.dy >= position.dy &&
        point.dy <= position.dy + size.height;
  }

  bool isInDeleteArea(Offset point) {
    return point.dx < position.dx &&
        point.dx >= (position.dx - xSize - 2 * xGap) &&
        point.dy < position.dy &&
        point.dy >= (position.dy - xSize - 2 * xGap);
  }

  bool isInEditArea(Offset point) {
    final size = getTextSize;
    return point.dx > position.dx + size.width &&
        point.dx <= position.dx + size.width + editSize + 2 * editGap &&
        point.dy > position.dy + size.height &&
        point.dy <= position.dy + size.height + editSize + 2 * editGap;
  }

  /// 还原成旋转之前的点
  Offset deRotatePoint(Offset point) {
    final textSize = getTextSize;
    final touchX = point.dx;
    final touchY = point.dy;
    // 创建一个旋转矩阵，绕Z轴旋转45度
    final rotationMatrix = Matrix4.rotationZ(-angle * (pi / 180));

    // 将点的坐标转换为Vector3类型
    final pointVector = math64.Vector3(
        touchX - position.dx - textSize.width * 0.5,
        touchY - position.dy - textSize.height * 0.5,
        0.0);

    // 应用旋转矩阵到点 (x, y)
    final rotatedPoint = rotationMatrix.perspectiveTransform(pointVector);

    final rawTouchPoint = Offset(
        rotatedPoint.x + position.dx + textSize.width * 0.5,
        rotatedPoint.y + position.dy + textSize.height * 0.5);
    return rawTouchPoint;
  }

  XBImageEditorOperaText({
    required this.position,
    required this.text,
    required this.color,
    required this.fontSize,
    required this.scale,
    this.angle = 0,
    this.isSelected = false,
    this.isTaping = false,
    this.isTapingEdit = false,
    required this.xSize,
    required this.xGap,
    required this.editSize,
    required this.editGap,
    required this.lineWidth,
  });

  @override
  XBImageEditorOpera deepCopy() {
    return XBImageEditorOperaText(
        position: position,
        text: text,
        color: color,
        fontSize: fontSize,
        scale: scale,
        angle: angle,
        isSelected: isSelected,
        isTaping: isTaping,
        isTapingEdit: isTapingEdit,
        xSize: xSize,
        xGap: xGap,
        editSize: editSize,
        editGap: editGap,
        lineWidth: lineWidth);
  }
}
