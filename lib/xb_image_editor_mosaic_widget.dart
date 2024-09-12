import 'package:flutter/material.dart';
import 'package:xb_scaffold/xb_scaffold.dart';
import 'xb_image_editor_config.dart';
import 'xb_image_editor_img_display_vm.dart';
import 'xb_image_editor_mosaic_width_util.dart';
import 'xb_image_editor_opera_mosaic.dart';
import 'xb_image_editor_painter_new.dart';

class XBImageEditorMosaicWidget
    extends XBImageEditorImgDisplay<XBImageEditorMosaicWidgetVM> {
  final XBImageEditorMosaicWidthUtil mosaicWidthUtil;
  const XBImageEditorMosaicWidget(
      {required this.mosaicWidthUtil,
      required super.image,
      required super.operaUtil,
      required super.onTaping,
      super.key});

  @override
  generateVM(BuildContext context) {
    return XBImageEditorMosaicWidgetVM(context: context);
  }

  @override
  Widget buildWidget(XBImageEditorMosaicWidgetVM vm, BuildContext context) {
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

class XBImageEditorMosaicWidgetVM
    extends XBImageEditorImgDisplayVM<XBImageEditorMosaicWidget> {
  XBImageEditorMosaicWidgetVM({required super.context});

  addOpera() {
    widget.operaUtil.add(XBImageEditorOperaMosaic(
        points: [],
        color: colors.randColor.withAlpha(80),
        lineWidth:
            widget.mosaicWidthUtil.selectedMosaicWidth * initDisplayScale,
        scale: operaScale));
  }

  int count = 0;

  addPoint(Offset point) {
    count++;
    int base = widget.mosaicWidthUtil.selectedMosaicWidth ~/
        widget.mosaicWidthUtil.mosaicWidths.first *
        3;
    if (count % base != 0) return;
    XBImageEditorOperaMosaic? lastMosaicOpera =
        widget.operaUtil.lastMosaicOpear;
    if (lastMosaicOpera == null) return;
    final temp = rawPosition(point);
    XBImageEditorOperaMosaicPoint mosaicPoint = XBImageEditorOperaMosaicPoint(
        color: colors.randColor.withAlpha(80), position: temp);
    lastMosaicOpera.points.add(mosaicPoint);
    widget.operaUtil.notify();
  }
}
