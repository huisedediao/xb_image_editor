import 'package:flutter/material.dart';
import 'xb_image_editor_color_selector.dart';
import 'xb_image_editor_color_util.dart';
import 'xb_image_editor_config.dart';
import 'xb_image_editor_mosaic_width_util.dart';
import 'xb_image_editor_opera_rotate.dart';
import 'xb_image_editor_rotate_selector.dart';
import 'xb_image_editor_width_selector.dart';

class XBImageEditorOperaBar extends StatelessWidget {
  final int operaIndex;
  final XBImageEditorColorUtil penColorUtil;
  final XBImageEditorMosaicWidthUtil mosaicWidthUtil;
  final XBImageEditorColorUtil textColorUtil;

  final ValueChanged<XBImageEditorOperaRotate> onRotateChanged;
  const XBImageEditorOperaBar(
      {required this.onRotateChanged,
      required this.penColorUtil,
      required this.mosaicWidthUtil,
      required this.operaIndex,
      required this.textColorUtil,
      super.key});

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isSelectedPen) {
      child = generatePenColorSelector();
    } else if (isSelectedText) {
      child = generateTextColorSelector();
    } else if (isSelectedClip) {
      child = generateRotateSelector();
    } else if (isSelectedMosaic) {
      child = generateWidthSelector();
    } else {
      child = Container();
    }
    return Container(
      color: xbImgEditorColorDarkGrey,
      height: 60,
      child: child,
    );
  }

  Widget generatePenColorSelector() {
    return XBImageEditorColorSelector(
      colors: colors,
      selectedIndex: penColorUtil.colorIndex,
      onIndexChanged: (value) {
        penColorUtil.colorIndex = value;
      },
    );
  }

  Widget generateTextColorSelector() {
    return XBImageEditorColorSelector(
      colors: colors,
      selectedIndex: textColorUtil.colorIndex,
      onIndexChanged: (value) {
        textColorUtil.colorIndex = value;
      },
    );
  }

  Widget generateRotateSelector() {
    return XBImageEditorRotateSelector(onRotateChanged: (angle) {
      onRotateChanged(XBImageEditorOperaRotate(
          rotate: angle == 0
              ? XBImageEditorOperaRotateEnum.anticlockwise
              : XBImageEditorOperaRotateEnum.clockwise));
    });
  }

  Widget generateWidthSelector() {
    return XBImageEditorWidth(
        widths: mosaicWidthUtil.mosaicWidths,
        selectedIndex: mosaicWidthUtil.mosaicWidthIndex,
        onWidthChanged: (value) {
          mosaicWidthUtil.mosaicWidthIndex = value;
        });
  }

  List<Color> get colors => [
        Colors.white,
        Colors.black,
        Colors.yellowAccent,
        Colors.orange,
        Colors.red,
        Colors.pink,
        Colors.purple,
        Colors.blueGrey,
        Colors.blue,
        Colors.green
      ];

  bool get isSelectedPen => operaIndex == 0;
  bool get isSelectedMosaic => operaIndex == 1;
  bool get isSelectedClip => operaIndex == 2;
  bool get isSelectedText => operaIndex == 3;
}
