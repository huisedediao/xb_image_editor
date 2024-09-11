import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'xb_image_editor_opera_clip.dart';
import 'xb_image_editor_opera_pen.dart';
import 'xb_image_editor_opera_util.dart';

class XBImageEditorPainter extends CustomPainter {
  final ui.Image uiImg;
  final XBImageEditorOperaUtil operaUtil;

  XBImageEditorPainter({required this.operaUtil, required this.uiImg});

  XBImageEditorOperaClip? get lastClipOpear => operaUtil.lastClipOpear;

  @override
  void paint(Canvas canvas, Size size) {
    /// 画图片
    {
      final imgPaint = Paint();
      // 图片展示的区域（裁剪的区域）
      Rect srcRect;

      final imgDisplayArea = lastClipOpear?.tlbr ?? [];
      if (imgDisplayArea.length == 2) {
        final x = imgDisplayArea.first.x;
        final y = imgDisplayArea.first.y;
        final w = imgDisplayArea.last.x - imgDisplayArea.first.x;
        final h = imgDisplayArea.last.y - imgDisplayArea.first.y;
        srcRect = Rect.fromLTWH(x, y, w, h);
      } else {
        srcRect = Rect.fromLTWH(
            0, 0, uiImg.width.toDouble(), uiImg.height.toDouble());
      }
      double imageAspectRatio;
      if (lastClipOpear != null) {
        imageAspectRatio =
            lastClipOpear!.newSize.width / lastClipOpear!.newSize.height;
      } else {
        imageAspectRatio = uiImg.width / uiImg.height;
      }

      double targetWidth, targetHeight;
      if (imageAspectRatio > 1) {
        // 图片宽度大于高度
        targetWidth = size.width;
        targetHeight = targetWidth / imageAspectRatio;
      } else {
        // 图片高度大于宽度
        targetHeight = size.height;
        targetWidth = targetHeight * imageAspectRatio;
      }

      final offsetX = (size.width - targetWidth) / 2;
      final offsetY = (size.height - targetHeight) / 2;
      final dstRect =
          Rect.fromLTWH(offsetX, offsetY, targetWidth, targetHeight);
      canvas.drawImageRect(uiImg, srcRect, dstRect, imgPaint);
    }

    /// 画轨迹
    {
      Paint paint = Paint()..strokeCap = StrokeCap.round;
      for (var opera in operaUtil.operas) {
        if (opera is XBImageEditorOperaPen) {
          paint.color = opera.color;
          paint.strokeWidth = opera.lineWidth;
          final points = opera.points;
          for (int i = 0; i < points.length - 1; i++) {
            // 画线段连接相邻的点
            canvas.drawLine(points[i], points[i + 1], paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
