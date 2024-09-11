import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'model/xb_image_editor_clip_mask_change_info.dart';
import 'xb_image_editor_clip_widget.dart';
import 'xb_image_editor_config.dart';
import 'xb_image_editor_mosaic_widget.dart';
import 'package:xb_scaffold/xb_scaffold.dart';
import 'xb_image_editor_mosaic_width_util.dart';
import 'xb_image_editor_opera_util.dart';
import 'xb_image_editor_pen_widget.dart';
import 'xb_image_editor_color_util.dart';
import 'xb_image_editor_text_widget.dart';

class XBImageEditorContent extends XBVMLessWidget {
  final ui.Image? image;

  final ValueChanged<XBImageEditorClipMaskChangeInfo> onAreaChanged;

  final XBImageEditorOperaType operaType;

  final XBImageEditorOperaUtil operaUtil;

  final XBImageEditorColorUtil penColorUtil;

  final XBImageEditorMosaicWidthUtil mosaicWidthUtil;

  final XBImageEditorColorUtil textColorUtil;

  const XBImageEditorContent(
      {required this.image,
      required this.onAreaChanged,
      required this.operaType,
      required this.operaUtil,
      required this.penColorUtil,
      required this.mosaicWidthUtil,
      required this.textColorUtil,
      super.key});

  @override
  Widget buildWidget(XBVM vm, BuildContext context) {
    if (image == null) {
      return Container();
    }

    return Container(
      color: xbImgEditorColorBlack,
      alignment: Alignment.center,
      child: RotatedBox(
          quarterTurns: -operaUtil.calculateRotate, child: childWidget(vm)),
    );
  }

  Widget childWidget(XBVM vm) {
    if (image == null) {
      return Container();
    }
    if (operaType == XBImageEditorOperaType.clip) {
      return XBImageEditorClipWidget(
          onAreaChanged: onAreaChanged,
          onTaping: (bool value) {},
          image: image!,
          operaUtil: operaUtil);
    } else if (operaType == XBImageEditorOperaType.pen) {
      return XBImageEditorPenWidget(
        onTaping: (bool value) {},
        image: image!,
        operaUtil: operaUtil,
        colorUtil: penColorUtil,
      );
    } else if (operaType == XBImageEditorOperaType.mosaic) {
      return XBImageEditorMosaicWidget(
        onTaping: (bool value) {},
        image: image!,
        operaUtil: operaUtil,
        mosaicWidthUtil: mosaicWidthUtil,
      );
    } else if (operaType == XBImageEditorOperaType.text) {
      return XBImageEditorTextWidget(
        onTaping: (bool value) {},
        image: image!,
        operaUtil: operaUtil,
        colorUtil: textColorUtil,
      );
    } else {
      return Container();
    }
  }
}
