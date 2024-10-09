import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:xb_scaffold/xb_scaffold.dart';
import 'model/xb_image_editor_clip_mask_change_info.dart';
import 'xb_image_editor.dart';
import 'xb_image_editor_color_util.dart';
import 'xb_image_editor_config.dart';
import 'xb_image_editor_funs.dart';
import 'xb_image_editor_mosaic_width_util.dart';
import 'xb_image_editor_opera_clip.dart';
import 'xb_image_editor_opera_rotate.dart';
import 'dart:ui' as ui;
import 'xb_image_editor_opera_util.dart';
import 'xb_image_editor_painter_new.dart';

class XBImageEditorVM extends XBPageVM<XBImageEditor> {
  ui.Image? image;

  late XBImageEditorOperaUtil operaUtil;
  List<XBImageEditorOpera> get operas => operaUtil.operas;

  XBImageEditorVM({required super.context}) {
    tempContext = context;
    inputTextTip_ = widget.inputTextTip;
    newText_ = widget.newText;
    cancelText_ = widget.cancelText;
    confirmText_ = widget.completeText;
    completeText_ = widget.completeText;
    clipText_ = widget.clipText;
    operaUtil = XBImageEditorOperaUtil(
      onChanged: () {
        notify();
      },
    );
    penColorUtil = XBImageEditorColorUtil(
      colors: colors,
      onChanged: () {
        notify();
      },
    );
    mosaicWidthUtil = XBImageEditorMosaicWidthUtil(onChanged: () {
      notify();
    });
    textColorUtil = XBImageEditorColorUtil(
      colors: colors,
      onChanged: () {
        notify();
      },
    );
    _setupOperas();
    _generateUiImg();
  }

  _setupOperas() {
    if (widget.initOperas != null) {
      operaUtil.operas = widget.initOperas!.map((e) => e.deepCopy()).toList();
    }
  }

  _generateUiImg() async {
    try {
      if (widget.img is ui.Image) {
        image = widget.img;
      } else if (widget.img is String) {
        String imgStr = widget.img;
        if (imgStr.startsWith("http")) {
          image = await generateUiImgFromNet(imgStr);
        } else if (imgStr.startsWith("asset")) {
          image = await generateUiImgFromAssetsPath(imgStr);
        } else {
          /// 沙盒
          image = await generateUiImgFromFilePath(imgStr);
        }
      } else if (widget.img is Uint8List) {
        image = await generateUiImgFromUint8List(widget.img);
      }
      if (image == null) {
        throw Exception("img type error");
      }
    } catch (e) {
      throw Exception("img type error");
    }
    notify();
  }

  Size? get rawSize => image == null
      ? null
      : Size(xbParse<double>(image!.width) ?? 0,
          xbParse<double>(image!.height) ?? 0);

  int contentKey = 0;

  XBImageEditorOperaType _operaType = XBImageEditorOperaType.pen;
  XBImageEditorOperaType get operaType => _operaType;
  set operaType(XBImageEditorOperaType newValue) {
    _operaType = newValue;
    operaUtil.unSelectedAllTextOpera();
    if (isNeedShowClipBtn) {
      _clip();
    }
    notify();
  }

  selectPen() {
    _operaType = XBImageEditorOperaType.pen;
    notify();
  }

  selectMosaic() {
    _operaType = XBImageEditorOperaType.mosaic;
    notify();
  }

  selectClip() {
    _operaType = XBImageEditorOperaType.clip;
    notify();
  }

  selectText() {
    _operaType = XBImageEditorOperaType.text;
    notify();
  }

  late XBImageEditorColorUtil penColorUtil;

  late XBImageEditorColorUtil textColorUtil;

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

  late XBImageEditorMosaicWidthUtil mosaicWidthUtil;

  addOpera(XBImageEditorOpera opera) {
    operas.add(opera);
  }

  onRotateChanged(XBImageEditorOperaRotate opera) {
    addOpera(opera);
    contentKey++;
    clipInfo = null;
    notify();
  }

  onPrevious() {
    if (operas.isEmpty) return;
    operas.removeLast();
    contentKey++;
    notify();
  }

  onClean() {
    if (operas.isEmpty) return;
    operas.clear();
    contentKey++;
    notify();
  }

  String get brTitle {
    return isNeedShowClipBtn ? (clipText_ ?? "裁剪") : (completeText_ ?? "完成");
  }

  onTapBr() async {
    if (isNeedShowClipBtn) {
      _clip();
    } else {
      if (image == null) return;
      if (operas.isEmpty) {
        XBImageEditorRet ret =
            XBImageEditorRet(imgData: null, operas: operas, size: Size.zero);
        pop(ret);
        return;
      }
      widget.onGenerateStart?.call();
      operaUtil.unSelectedAllTextOpera();
      notify();
      Size size;
      final lastClipOpear = operaUtil.lastClipOpear;
      if (lastClipOpear == null) {
        size = Size(image!.width.toDouble(), image!.height.toDouble());
      } else {
        size = lastClipOpear.newSize;
      }
      Uint8List? retImg = await convertPainterToImage(
          XBImageEditorPainterNew(operaUtil: operaUtil, uiImg: image!), size);
      if (retImg != null) {
        Size newSize = operaUtil.lastClipOpear?.newSize ??
            Size(image!.width * 1.0, image!.height * 1.0);
        if (operaUtil.angle != 0) {
          retImg = await rotateImage(retImg, operaUtil.angle);
          if (!operaUtil.isV) {
            newSize = Size(newSize.height, newSize.width);
          }
        }
        XBImageEditorRet ret =
            XBImageEditorRet(imgData: retImg, operas: operas, size: newSize);
        widget.onGenerateFinish?.call();
        pop(ret);
      } else {
        widget.onGenerateFinish?.call();
        pop();
      }
    }
  }

  _clip() {
    final previousClipOpera = lastClipOpear;
    final referenceTL = previousClipOpera != null
        ? previousClipOpera.newTL
        : const Point(0.0, 0.0);
    final referenceSize = previousClipOpera != null
        ? previousClipOpera.newSize
        : Size(image!.width * 1.0, image!.height * 1.0);
    operas.add(XBImageEditorOperaClip(
        clipInfo: clipInfo!,
        referenceTL: referenceTL,
        referenceSize: referenceSize));
    clipInfo = null;
    contentKey++;
    notify();
  }

  XBImageEditorOperaClip? get lastClipOpear {
    for (int i = operas.length - 1; i >= 0; i--) {
      final temp = operas[i];
      if (temp is XBImageEditorOperaClip) {
        return temp;
      }
    }
    return null;
  }

  XBImageEditorClipMaskChangeInfo? clipInfo;
  bool get isNeedShowClipBtn => clipInfo != null;
  onAreaChanged(XBImageEditorClipMaskChangeInfo value) {
    clipInfo = value;
    notify();
  }

  @override
  void dispose() {
    tempContext = null;
    super.dispose();
  }
}
