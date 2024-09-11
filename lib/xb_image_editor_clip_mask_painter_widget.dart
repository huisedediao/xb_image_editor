import 'package:flutter/material.dart';
import 'model/xb_image_editor_graph_model.dart';

class XBImageEditorClipMaskPainterWidget extends StatefulWidget {
  final double width;
  final double height;
  final List<XBImageEditorGraphModel> initModels;
  const XBImageEditorClipMaskPainterWidget(
      {required this.width,
      required this.height,
      required this.initModels,
      super.key});

  @override
  State<XBImageEditorClipMaskPainterWidget> createState() =>
      XBImageEditorClipMaskPainterWidgetState();
}

class XBImageEditorClipMaskPainterWidgetState
    extends State<XBImageEditorClipMaskPainterWidget> {
  late List<XBImageEditorGraphModel> models;

  @override
  void initState() {
    super.initState();
    models = widget.initModels;
  }

  updateModel(List<XBImageEditorGraphModel> newValue) {
    models = newValue;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: XBImageEditorClipMaskPainter(models: models),
    );
  }
}

class XBImageEditorClipMaskPainter extends CustomPainter {
  final List<XBImageEditorGraphModel> models;
  XBImageEditorClipMaskPainter({required this.models});
  double get _pw => 5;

  @override
  void paint(Canvas canvas, Size size) {
    for (var model in models) {
      Paint paint = Paint()
        ..color = const Color.fromRGBO(0, 0, 0, 0)
        ..style = PaintingStyle.fill;

      Paint borderPaint = Paint()
        ..color =
            Color.fromRGBO(model.rgba![0], model.rgba![1], model.rgba![2], 1)
        ..strokeWidth = model.lineWidth ?? (_pw * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      Paint pointPaint = Paint()
        ..color =
            Color.fromRGBO(model.rgba![0], model.rgba![1], model.rgba![2], 1)
        ..style = PaintingStyle.fill;

      if (model.points != null && model.points!.isNotEmpty) {
        // 绘制蓝色区域
        canvas.saveLayer(Rect.largest, Paint());
        canvas.drawRect(
            Offset.zero & size, Paint()..color = Colors.black.withAlpha(100));

        final clearRect = Rect.fromPoints(
            Offset(model.points?[0].x ?? 0, model.points?[0].y ?? 0),
            Offset(model.points?[2].x ?? 0, model.points?[2].y ?? 0));

        // 在正方形区域内裁剪掉蓝色，显示底下的图片
        canvas.clipRect(clearRect);
        canvas.drawRect(clearRect, Paint()..blendMode = BlendMode.clear);
        canvas.restore();

        Path path = Path();
        final firstX = model.points![0].x!.toDouble();
        final firstY = model.points![0].y!.toDouble();
        path.moveTo(firstX, firstY);
        canvas.drawCircle(
            Offset(firstX, firstY),
            _pw, // radius of the circle
            pointPaint);
        for (int i = 1; i < model.points!.length; i++) {
          double x;
          double y;
          if (i == 1) {
            x = model.points![i].x!.toDouble();
            y = model.points![i].y!.toDouble();
          } else if (i == 2) {
            x = model.points![i].x!.toDouble();
            y = model.points![i].y!.toDouble();
          } else {
            x = model.points![i].x!.toDouble();
            y = model.points![i].y!.toDouble();
          }
          path.lineTo(x, y);
          // Draw a circle for each point
          canvas.drawCircle(
              Offset(x, y),
              _pw, // radius of the circle
              pointPaint);
        }

        /// Close the path by connecting the last point to the first point
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
