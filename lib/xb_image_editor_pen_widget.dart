import 'package:flutter/material.dart';
import 'package:xb_scaffold/xb_scaffold.dart';
import 'xb_image_editor_config.dart';
import 'xb_image_editor_img_display_vm.dart';
import 'xb_image_editor_color_util.dart';
import 'xb_image_editor_opera_pen.dart';
import 'xb_image_editor_painter_new.dart';

class XBImageEditorPenWidget
    extends XBImageEditorImgDisplay<XBImageEditorPenWidgetVM> {
  final XBImageEditorColorUtil colorUtil;
  const XBImageEditorPenWidget(
      {required super.image,
      required super.operaUtil,
      required super.onTaping,
      required this.colorUtil,
      super.key});

  @override
  generateVM(BuildContext context) {
    return XBImageEditorPenWidgetVM(context: context);
  }

  @override
  Widget buildWidget(XBImageEditorPenWidgetVM vm, BuildContext context) {
    final fixedSize = vm.fixedImgSize;
    Widget child = CustomPaint(
      painter: XBImageEditorPainterNew(operaUtil: operaUtil, uiImg: image),
    );
    return Center(
      child: GestureDetector(
        onPanDown: (details) {
          onTaping(true);
          final fixedPosition = vm.rawPosition(details.localPosition);
          final touchX = fixedPosition.dx;
          final touchY = fixedPosition.dy;
          xbError("touchX:$touchX,touchY:$touchY");

          vm.lastPoint = Offset(touchX, touchY);
          vm.addOpera();
        },
        onPanStart: (details) {},
        onPanUpdate: (details) {
          final touchX = details.localPosition.dx;
          final touchY = details.localPosition.dy;
          vm.addPoint(Offset(touchX, touchY));
        },
        onPanCancel: () {
          onTaping(false);
          vm.lastPoint = Offset.zero;
        },
        onPanEnd: (details) {
          onTaping(false);
          vm.lastPoint = Offset.zero;
        },
        child: Container(
          color: xbImageEditorColorBlack,
          // color: Colors.green,
          width: vm.contentSize.width,
          height: vm.contentSize.height,
          alignment: Alignment.center,
          child: ClipRRect(
            child: Container(
              color: Colors.yellow,
              width: fixedSize.width,
              height: fixedSize.height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class XBImageEditorPenWidgetVM
    extends XBImageEditorImgDisplayVM<XBImageEditorPenWidget> {
  XBImageEditorPenWidgetVM({required super.context});

  addOpera() {
    widget.operaUtil.add(XBImageEditorOperaPen(
        points: [],
        color: widget.colorUtil.selectedColor,
        scale: operaScale,
        lineWidth: 5 * initDisplayScale));
  }

  addPoint(Offset point) {
    XBImageEditorOperaPen? lastPenOpera = widget.operaUtil.lastPenOpear;
    if (lastPenOpera == null) return;
    final temp = rawPosition(point);
    lastPenOpera.points.add(temp);
    widget.operaUtil.notify();
  }
}
