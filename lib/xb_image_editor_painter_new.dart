import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'xb_image_editor_opera_clip.dart';
import 'xb_image_editor_opera_mosaic.dart';
import 'xb_image_editor_opera_pen.dart';
import 'xb_image_editor_opera_text.dart';
import 'xb_image_editor_opera_util.dart';

class XBImageEditorPainterNew extends CustomPainter {
  final ui.Image uiImg;
  final XBImageEditorOperaUtil operaUtil;

  XBImageEditorPainterNew({required this.operaUtil, required this.uiImg});

  XBImageEditorOperaClip? get lastClipOpear => operaUtil.lastClipOpear;

  @override
  void paint(Canvas canvas, Size size) {
    Size displayImgPart;
    Point<double> displayImgTl;
    if (lastClipOpear != null) {
      displayImgPart = lastClipOpear!.newSize;
      displayImgTl = lastClipOpear!.newTL;
    } else {
      displayImgPart = Size(uiImg.width * 1.0, uiImg.height * 1.0);
      displayImgTl = const Point(0, 0);
    }

    final xScale = size.width / displayImgPart.width;
    final yScale = size.height / displayImgPart.height;

    canvas.scale(xScale, yScale);
    canvas.translate(-displayImgTl.x, -displayImgTl.y);

    /// 画图片
    {
      final imgPaint = Paint();
      canvas.drawImage(uiImg, Offset.zero, imgPaint);
    }

    /// 画马赛克
    {
      final mosaicPaint = Paint()..style = PaintingStyle.fill;
      for (var opera in operaUtil.operas) {
        if (opera is XBImageEditorOperaMosaic) {
          final width = opera.lineWidth * opera.scale;
          for (var element in opera.points) {
            mosaicPaint.color = element.color;
            final position = element.position;
            canvas.drawRect(
              Rect.fromCenter(
                center: position,
                width: width, // You can change the size of mosaics
                height: width,
              ),
              mosaicPaint,
            );
          }
        }
      }
    }

    /// 画轨迹
    {
      Paint paint = Paint()..strokeCap = StrokeCap.round;
      for (var opera in operaUtil.operas) {
        if (opera is XBImageEditorOperaPen) {
          paint.color = opera.color;
          paint.strokeWidth = opera.lineWidth * opera.scale;
          final points = opera.points;
          for (int i = 0; i < points.length - 1; i++) {
            // 画线段连接相邻的点
            canvas.drawLine(points[i], points[i + 1], paint);
          }
        }
      }
    }

    /// 画文字
    {
      TextSpan textSpan;
      TextPainter textPainter;
      final rectBorderPaint = Paint()..style = PaintingStyle.stroke;

      for (var opera in operaUtil.operas) {
        if (opera is XBImageEditorOperaText) {
          rectBorderPaint.color = opera.color;
          textSpan = TextSpan(
            text: opera.text,
            style: TextStyle(
                color: opera.color, fontSize: opera.fontSize * opera.scale),
          );
          textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          // 保存当前画布状态
          canvas.save();

          // 将画布的中心点平移到文本的位置
          canvas.translate(opera.position.dx + textPainter.width / 2,
              opera.position.dy + textPainter.height / 2);

          // 旋转（以弧度表示：45度 = pi/4）
          canvas.rotate(opera.angle * 3.1415927 / 180);

          // 重新将画布的参考点平移回文本左上角
          canvas.translate(-textPainter.width / 2, -textPainter.height / 2);

          if (opera.isSelected) {
            /// 为文字添加边框
            final rect = Rect.fromLTWH(
              0,
              0,
              textPainter.size.width,
              textPainter.size.height,
            );
            rectBorderPaint.strokeWidth = 1 * opera.scale;
            canvas.drawRect(rect, rectBorderPaint);

            // 绘制删除的“X”
            final xPaint = Paint()
              ..color = opera.color
              ..strokeWidth = 1 * opera.scale; // X的颜色
            final xSize = opera.xSize; // X的大小
            final gap = opera.xGap;
            canvas.drawLine(
              Offset(-xSize - gap, -xSize - gap),
              Offset(-gap, -gap),
              xPaint,
            );
            canvas.drawLine(
              Offset(-gap, -xSize - gap),
              Offset(-xSize - gap, -gap),
              xPaint,
            );
          }

          // 绘制文字
          textPainter.paint(canvas, const Offset(0, 0));

          _drawSelectedStateIfNeed(
              textOpera: opera,
              rb: Offset(textPainter.size.width, textPainter.height),
              canvas: canvas);

          // 恢复画布状态
          canvas.restore();
        }
      }
    }
  }

  _drawSelectedStateIfNeed(
      {required XBImageEditorOperaText textOpera,
      required Offset rb,
      required Canvas canvas}) {
    if (textOpera.isSelected) {
      final selectedSquarePaint = Paint()
        ..color = textOpera.color
        ..strokeWidth = 1.0 * textOpera.scale
        ..style = PaintingStyle.stroke;

      // Calculate the position of the small square at the lower right corner
      final squareSize = textOpera
          .editSize; // Adjust this value to change the size of the square
      final squareRect = Rect.fromLTWH(
        rb.dx + textOpera.editGap,
        rb.dy + textOpera.editGap,
        squareSize,
        squareSize,
      );

      // canvas.drawRect(rect, selectedSquarePaint);

      // canvas.drawRect(squareRect, selectedSquarePaint);

      // Define the size of the corners
      final cornerSize = squareSize * 0.33;

      // Save the current canvas state
      canvas.save();

      // Translate the canvas origin to the center of the square
      canvas.translate(squareRect.center.dx, squareRect.center.dy);

      // Rotate the canvas by 45 degrees
      // canvas.rotate(pi / 4);

      // Draw a circle in the middle of the square
      final circleRadius = 1 * textOpera.scale; // Radius for a 5x5 circle
      final circlePaint = Paint()
        ..color = textOpera.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(0, 0), circleRadius, circlePaint);

      // Translate the canvas origin back
      canvas.translate(-squareRect.center.dx, -squareRect.center.dy);

      // Create a path for the corners of the square
      final path = Path()
        ..moveTo(squareRect.left, squareRect.top + cornerSize)
        ..lineTo(squareRect.left, squareRect.top)
        ..lineTo(squareRect.left + cornerSize, squareRect.top)
        ..moveTo(squareRect.right - cornerSize, squareRect.top)
        ..lineTo(squareRect.right, squareRect.top)
        ..lineTo(squareRect.right, squareRect.top + cornerSize)
        ..moveTo(squareRect.right, squareRect.bottom - cornerSize)
        ..lineTo(squareRect.right, squareRect.bottom)
        ..lineTo(squareRect.right - cornerSize, squareRect.bottom)
        ..moveTo(squareRect.left + cornerSize, squareRect.bottom)
        ..lineTo(squareRect.left, squareRect.bottom)
        ..lineTo(squareRect.left, squareRect.bottom - cornerSize);

      // Draw the corners of the square
      canvas.drawPath(path, selectedSquarePaint);

      // Restore the canvas state
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
