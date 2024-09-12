import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as math64;
import 'package:xb_scaffold/xb_scaffold.dart';
import 'xb_image_editor_config.dart';
import 'xb_image_editor_funs.dart';
import 'xb_image_editor_img_display_vm.dart';
import 'xb_image_editor_color_util.dart';
import 'xb_image_editor_opera_text.dart';
import 'xb_image_editor_painter_new.dart';

class XBImageEditorTextWidget
    extends XBImageEditorImgDisplay<XBImageEditorTextWidgetVM> {
  final XBImageEditorColorUtil colorUtil;
  const XBImageEditorTextWidget(
      {required super.image,
      required super.operaUtil,
      required super.onTaping,
      required this.colorUtil,
      super.key});

  @override
  generateVM(BuildContext context) {
    return XBImageEditorTextWidgetVM(context: context);
  }

  @override
  Widget buildWidget(XBImageEditorTextWidgetVM vm, BuildContext context) {
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
          Offset point = Offset(touchX, touchY);
          vm.lastPoint = point;

          /// 判断是否在已经有的文字的范围
          XBImageEditorOperaText? selectedTextOpera =
              vm.findSelectedText(point);
          if (selectedTextOpera != null) {
            operaUtil.unTapingAllTextOpera();
            selectedTextOpera.isTaping = true;
            return;
          }

          /// 判断是否在已经有的文字的拖动按钮范围
          XBImageEditorOperaText? editTextOpera = vm.findEditText(point);
          if (editTextOpera != null) {
            operaUtil.unTapingEditAllTextOpera();
            editTextOpera.isTapingEdit = true;
            return;
          }
        },
        onPanStart: (details) {},
        onPanUpdate: (details) {
          final touchX = details.localPosition.dx;
          final touchY = details.localPosition.dy;
          vm.panUpdate(Offset(touchX, touchY));
        },
        onPanCancel: () {
          onTaping(false);
          vm.lastPoint = Offset.zero;
          operaUtil.unTapingAllTextOpera();
          operaUtil.unTapingEditAllTextOpera();
        },
        onPanEnd: (details) {
          onTaping(false);
          vm.lastPoint = Offset.zero;
          operaUtil.unTapingAllTextOpera();
          operaUtil.unTapingEditAllTextOpera();
        },
        onTapUp: (details) {
          vm.onTapUp(details);
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

class XBImageEditorTextWidgetVM
    extends XBImageEditorImgDisplayVM<XBImageEditorTextWidget> {
  XBImageEditorTextWidgetVM({required super.context});

  XBImageEditorOperaText? findSelectedText(Offset point) {
    for (var element in widget.operaUtil.operas) {
      if (element is XBImageEditorOperaText) {
        bool isInArea = element.isInArea(element.deRotatePoint(point));
        if (isInArea) {
          return element;
        }
      }
    }
    return null;
  }

  XBImageEditorOperaText? findEditText(Offset point) {
    // 必须是选中状态，才有编辑按钮
    final textOpera = widget.operaUtil.selectedTextOpear;
    if (textOpera != null) {
      if (textOpera.isInEditArea(textOpera.deRotatePoint(point))) {
        return textOpera;
      }
    }
    return null;
  }

  /// pan不会触发
  onTapUp(TapUpDetails details) {
    final fixedPosition = rawPosition(details.localPosition);
    final touchX = fixedPosition.dx;
    final touchY = fixedPosition.dy;
    xbError("touchX:$touchX,touchY:$touchY");
    Offset point = Offset(touchX, touchY);
    xbError("onTapUp");

    final selectedTextOpear = widget.operaUtil.selectedTextOpear;
    if (selectedTextOpear != null) {
      final rawTouchPoint = selectedTextOpear.deRotatePoint(point);
      if (selectedTextOpear.isInDeleteArea(rawTouchPoint)) {
        // 删除
        widget.operaUtil.delete(selectedTextOpear);
        notify();
        return;
      }
    }

    XBImageEditorOperaText? selectedTextOpera = findSelectedText(point);
    if (selectedTextOpera == null) {
      // 添加
      addOpera(point);
      return;
    }

    if (selectedTextOpera.isSelected == false) {
      widget.operaUtil.unSelectedAllTextOpera();
      selectedTextOpera.isSelected = true;
      notify();
      return;
    }

    notify();
    // 编辑
    String text = selectedTextOpera.text;

    Future.delayed(const Duration(milliseconds: 1000), () {});
    dialogContent(
        title: inputTextTip_ ?? "请输入文字",
        content: XBBG(
            child: XBTextField(
          focused: true,
          onChanged: (value) {
            text = value;
          },
          placeholder: inputTextTip_ ?? "请输入文字",
          initValue: text,
        )),
        btnTitles: [cancelText_ ?? "取消", confirmText_ ?? "确定"],
        onSelected: (dlIndex) {
          if (dlIndex == 1) {
            selectedTextOpera.text = text;
            widget.operaUtil.notify();
          }
        });
  }

  addOpera(Offset point) {
    widget.operaUtil.unSelectedAllTextOpera();
    String tip = newText_ ?? "点击修改文字";
    final tempPosition = point;
    double fontSize = 14 * initDisplayScale;

    final tempSize = textSize(tip, TextStyle(fontSize: fontSize * operaScale));

    widget.operaUtil.add(XBImageEditorOperaText(
        text: tip,
        color: widget.colorUtil.selectedColor,
        scale: operaScale,
        fontSize: fontSize,
        position: Offset(tempPosition.dx - tempSize.width * 0.5,
            tempPosition.dy - tempSize.height * 0.5),
        isSelected: true,
        xSize: 13 * initDisplayScale * operaScale,
        xGap: 2.5 * initDisplayScale * operaScale,
        editSize: 15 * initDisplayScale * operaScale,
        editGap: 2.5 * initDisplayScale * operaScale,
        angle: widget.operaUtil.calculateRotate * 90,
        lineWidth: 1 * initDisplayScale));
    widget.operaUtil.notify();
  }

  panUpdate(Offset point) {
    final temp = rawPosition(point);

    /// 移动
    XBImageEditorOperaText? tapingTextOpera = widget.operaUtil.tapingTextOpear;
    if (tapingTextOpera != null) {
      widget.operaUtil.unSelectedAllTextOpera();
      tapingTextOpera.isSelected = true;
      notify();

      if (lastPoint != Offset.zero) {
        final xDif = temp.dx - lastPoint.dx;
        final yDif = temp.dy - lastPoint.dy;
        tapingTextOpera.position = Offset(tapingTextOpera.position.dx + xDif,
            tapingTextOpera.position.dy + yDif);
      }
      lastPoint = temp;
      notify();
      return;
    }

    /// 旋转和缩放
    XBImageEditorOperaText? tapingEditOpera =
        widget.operaUtil.tapingEditTextOpear;
    if (tapingEditOpera != null) {
      // 处理编辑文本的逻辑
      final tempTextSize = tapingEditOpera.getTextSize;
      final centerX = tapingEditOpera.position.dx + tempTextSize.width * 0.5;
      final centerY = tapingEditOpera.position.dy + tempTextSize.height * 0.5;

      /// 旋转
      if (lastPoint != Offset.zero) {
        // 计算旋转角度
        math64.Vector3 v1 =
            math64.Vector3(lastPoint.dx - centerX, lastPoint.dy - centerY, 0);
        math64.Vector3 v2 =
            math64.Vector3(temp.dx - centerX, temp.dy - centerY, 0);

        // 计算夹角和旋转方向
        double angle = calculateAngleBetweenVectors(v2, v1);
        tapingEditOpera.angle += radiansToDegrees(-angle); // 更新角度

        // 更新最后一个点
        lastPoint = temp;
        notify();
      }

      // 原始右下角
      final Offset br = Offset(tapingEditOpera.position.dx + tempTextSize.width,
          tapingEditOpera.position.dy + tempTextSize.height);

      // 计算中心到右下角的距离
      final c2brDistance = (br - Offset(centerX, centerY)).distance.abs();
      final c2CurrentPointDistance =
          (temp - Offset(centerX, centerY)).distance.abs();
      double distanceScale = c2CurrentPointDistance / c2brDistance;

      /// 缩放
      final difX = tempTextSize.width * distanceScale - tempTextSize.width;
      final difY = tempTextSize.height * distanceScale - tempTextSize.height;
      // 更新position
      final newPosition = Offset(tapingEditOpera.position.dx - difX * 0.5,
          tapingEditOpera.position.dy - difY * 0.5);
      final newFontSize = tapingEditOpera.fontSize * distanceScale;

      tapingEditOpera.position = newPosition;
      tapingEditOpera.fontSize = newFontSize;

      notify();
    }
  }

  double radiansToDegrees(double radians) {
    return radians * (180 / pi);
  }

  double calculateAngleBetweenVectors(math64.Vector3 v1, math64.Vector3 v2) {
    // 使用 atan2 计算角度
    double angleV1 = atan2(v1.y, v1.x);
    double angleV2 = atan2(v2.y, v2.x);

    // 计算角度差
    double angleDifference = angleV2 - angleV1;

    // 确保角度在 -π 到 π 之间
    if (angleDifference > pi) {
      angleDifference -= 2 * pi;
    } else if (angleDifference < -pi) {
      angleDifference += 2 * pi;
    }

    return angleDifference; // 返回弧度
  }
}
