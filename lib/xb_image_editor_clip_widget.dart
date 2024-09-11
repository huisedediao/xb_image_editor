import 'package:flutter/material.dart';
import 'package:xb_scaffold/xb_scaffold.dart';
import 'model/xb_image_editor_clip_mask_change_info.dart';
import 'model/xb_image_editor_graph_model.dart';
import 'xb_image_editor_clip_mask_painter_widget.dart';
import 'xb_image_editor_config.dart';
import 'xb_image_editor_img_display_vm.dart';
import 'xb_image_editor_painter_new.dart';

class XBImageEditorClipWidget
    extends XBImageEditorImgDisplay<XBImageEditorClipWidgetVM> {
  /// 区域变化回调
  final ValueChanged<XBImageEditorClipMaskChangeInfo> onAreaChanged;

  const XBImageEditorClipWidget(
      {required this.onAreaChanged,
      required super.onTaping,
      required super.image,
      required super.operaUtil,
      super.key});

  @override
  generateVM(BuildContext context) {
    return XBImageEditorClipWidgetVM(context: context);
  }

  @override
  Widget buildWidget(XBImageEditorClipWidgetVM vm, BuildContext context) {
    final fixedSize = vm.fixedImgSize;
    Widget child = CustomPaint(
      painter: XBImageEditorPainterNew(operaUtil: operaUtil, uiImg: image),
    );
    return Center(
      child: GestureDetector(
        onPanDown: (details) {
          final fixedTouchPosition = vm.fixTouchPosition(details.localPosition);

          onTaping(true);
          final touchX = fixedTouchPosition.dx;
          final touchY = fixedTouchPosition.dy;
          xbError("touchX:$touchX,touchY:$touchY");
          final point = vm.selectedModel.findInsidePoint(touchX, touchY);
          if (point != null) {
            point.isSelected = true;
          } else {
            vm.isPointInsidePolygon =
                vm.selectedModel.isPointInsidePolygon(touchX, touchY);
            vm.lastPoint = Offset(touchX, touchY);
            // Console.error("isInside :${vm.isPointInsidePolygon}");
          }
        },
        onPanStart: (details) {},
        onPanUpdate: (details) {
          final fixedTouchPosition = vm.fixTouchPosition(details.localPosition);
          final touchX = fixedTouchPosition.dx;
          final touchY = fixedTouchPosition.dy;
          if (vm.isPointInsidePolygon) {
            final offset =
                Offset(touchX - vm.lastPoint.dx, touchY - vm.lastPoint.dy);
            // if (!vm.selectedModel.isAllPointInBoundsAfterOffset(
            //     offset, 0, fixedSize.width, 0, fixedSize.height)) {
            //   return;
            // }
            // vm.selectedModel.translatePoints(offset);
            vm.selectedModel.translatePointsAutoFix(
                offset, 0, fixedSize.width, 0, fixedSize.height);
            vm.lastPoint = Offset(touchX, touchY);

            vm.globalKey.currentState?.updateModel([vm.selectedModel]);

            onAreaChanged(XBImageEditorClipMaskChangeInfo(
                model: vm.selectedModel, displaySize: vm.displaySize));
          } else {
            final point = vm.selectedModel.findSelectedPoint();
            if (point != null) {
              var newX = touchX;
              var newY = touchY;
              if (newX < 0) {
                newX = 0;
              }
              if (newY < 0) {
                newY = 0;
              }
              if (newX > fixedSize.width) {
                newX = fixedSize.width;
              }
              if (newY > fixedSize.height) {
                newY = fixedSize.height;
              }
              // if (!vm.selectedModel
              //     .isDistanceGreaterThanRadiusToAll(newX, newY)) {
              //   return;
              // }
              vm.updatePointAndNearPointsAutoFix(point, newX, newY);
              vm.globalKey.currentState?.updateModel([vm.selectedModel]);

              onAreaChanged(XBImageEditorClipMaskChangeInfo(
                  model: vm.selectedModel, displaySize: vm.displaySize));
            }
          }
        },
        onPanCancel: () {
          onTaping(false);
          final point = vm.selectedModel.findSelectedPoint();
          if (point != null) {
            point.isSelected = false;
          }
          vm.isPointInsidePolygon = false;
          vm.lastPoint = Offset.zero;
        },
        onPanEnd: (details) {
          onTaping(false);
          final point = vm.selectedModel.findSelectedPoint();
          if (point != null) {
            point.isSelected = false;
          }
          vm.isPointInsidePolygon = false;
          vm.lastPoint = Offset.zero;
        },
        child: Container(
          color: xbImgEditorColorBlack,
          // color: Colors.green,
          width: vm.contentSize.width,
          height: vm.contentSize.height,
          alignment: Alignment.center,
          child: Container(
            color: Colors.yellow,
            width: fixedSize.width,
            height: fixedSize.height,
            child: Stack(
              children: [
                Positioned.fill(
                    child: ClipRRect(child: Container(child: child))),
                Positioned.fill(
                    child: XBImageEditorClipMaskPainterWidget(
                  key: vm.globalKey,
                  width: fixedSize.width,
                  height: fixedSize.height,
                  initModels: [vm.selectedModel],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class XBImageEditorClipWidgetVM
    extends XBImageEditorImgDisplayVM<XBImageEditorClipWidget> {
  GlobalKey<XBImageEditorClipMaskPainterWidgetState> globalKey = GlobalKey();

  /// 转成图片上的坐标
  Offset fixTouchPosition(Offset localPosition) {
    final paddingX = (contentSize.width - fixedImgSize.width) * 0.5;
    final paddingY = (contentSize.height - fixedImgSize.height) * 0.5;

    double x;
    double y;

    if (localPosition.dx < paddingX) {
      x = -(paddingX - localPosition.dx);
    } else {
      x = localPosition.dx - paddingX;
    }

    if (localPosition.dy < paddingY) {
      y = -(paddingY - localPosition.dy);
    } else {
      y = localPosition.dy - paddingY;
    }
    return Offset(x, y);
  }

  @override
  double get padding => 20;

  bool isPointInsidePolygon = false;

  @override
  widgetSizeDidChanged() {
    xbError("widgetSize:$widgetSize");
    final fixedSize = fixedImgSize;
    const double x = 0;
    const double y = 0;
    final w = fixedSize.width;
    final h = fixedSize.height;
    models = [
      XBImageEditorGraphModel(
          type: XBImageEditorGraphModel.typeArea,
          id: XBImageEditorGraphModel.getId,
          rgba: [255, 255, 255, 125],
          lineWidth: 0,
          abType: XBImageEditorGraphModel.abTypeDef,
          name:
              XBImageEditorGraphModel.getName(XBImageEditorGraphModel.typeArea),
          points: [
            XBImageEditorGraphModelPoints(x: x, y: y),
            XBImageEditorGraphModelPoints(x: x + w, y: y),
            XBImageEditorGraphModelPoints(x: x + w, y: y + h),
            XBImageEditorGraphModelPoints(x: x, y: y + h)
          ])
    ];
  }

  XBImageEditorClipWidgetVM({required super.context});

  XBImageEditorGraphModelPoints findSameXPoint(
      XBImageEditorGraphModelPoints point) {
    for (var element in models.first.points!) {
      if (element.x == point.x && element != point) {
        return element;
      }
    }
    return point;
  }

  XBImageEditorGraphModelPoints findSameYPoint(
      XBImageEditorGraphModelPoints point) {
    for (var element in models.first.points!) {
      if (element.y == point.y && element != point) {
        return element;
      }
    }
    return point;
  }

  updatePointAndNearPoints(
      XBImageEditorGraphModelPoints point, double newX, double newY) async {
    final sameXPoint = findSameXPoint(point);
    final sameYPoint = findSameYPoint(point);
    sameXPoint.x = newX;
    sameYPoint.y = newY;
    point.x = newX;
    point.y = newY;
    notify();
  }

  double minBorderW = 50;

  updatePointAndNearPointsAutoFix(
      XBImageEditorGraphModelPoints point, double newX, double newY) async {
    final sameXPoint = findSameXPoint(point);
    final sameYPoint = findSameYPoint(point);

    bool pointIsBottom = point.y! > sameXPoint.y!;
    bool pointIsRight = point.x! > sameYPoint.x!;

    double xDif = newX - sameYPoint.x!;
    double yDif = newY - sameXPoint.y!;

    bool canMoveX = (pointIsRight && xDif > 0 || !pointIsRight && xDif < 0) &&
        xDif.abs() > minBorderW;
    bool canMoveY = (pointIsBottom && yDif > 0 || !pointIsBottom && yDif < 0) &&
        yDif.abs() > minBorderW;
    if (canMoveX) {
      sameXPoint.x = newX;
      point.x = newX;
    }
    if (canMoveY) {
      sameYPoint.y = newY;
      point.y = newY;
    }
    notify();
  }

  Size get displaySize => fixedImgSize;

  XBImageEditorGraphModel get selectedModel => models[0];

  late List<XBImageEditorGraphModel> models;
}
