import 'dart:math';
import 'package:flutter/material.dart';
import 'package:xb_scaffold/xb_scaffold.dart';
import 'xb_image_editor_funs.dart';
import 'dart:ui' as ui;
import 'xb_image_editor_opera_clip.dart';
import 'xb_image_editor_opera_util.dart';

abstract class XBImageEditorImgDisplay<T extends XBVM> extends XBWidget<T> {
  final ui.Image image;
  final XBImageEditorOperaUtil operaUtil;
  final ValueChanged<bool> onTaping;
  const XBImageEditorImgDisplay(
      {required this.image,
      required this.operaUtil,
      required this.onTaping,
      super.key});

  XBImageEditorOperaClip? get lastClipOpear => operaUtil.lastClipOpear;
}

abstract class XBImageEditorImgDisplayVM<T extends XBImageEditorImgDisplay>
    extends XBVM<T> {
  XBImageEditorImgDisplayVM({required super.context});

  Offset lastPoint = Offset.zero;

  double get padding => 0;

  Size get fixedImgSize {
    Size imgSize;
    if (widget.lastClipOpear != null) {
      imgSize = widget.lastClipOpear!.newSize;
    } else {
      imgSize = Size(widget.image.width * 1.0, widget.image.height * 1.0);
    }

    return fixImgSize(imgSize);
  }

  Size fixImgSize(Size imgSize) {
    final tempContentSize = imgMaxSize;

    Size fitedSize = fitSize(
        Size(tempContentSize.width - padding * 2,
            tempContentSize.height - padding * 2),
        imgSize,
        true);

    return Size(fitedSize.width, fitedSize.height);
  }

  Size get imgMaxSize {
    Size imgSize;
    if (widget.lastClipOpear != null) {
      imgSize = widget.lastClipOpear!.newSize;
    } else {
      imgSize = Size(widget.image.width * 1.0, widget.image.height * 1.0);
    }

    Size fitedSize = fitSize(widgetSize, imgSize, true);

    Size contentSize =
        Size(fitedSize.width + padding * 2, fitedSize.height + padding * 2);
    contentSize = fitSize(widgetSize, contentSize);
    return contentSize;
  }

  Size get contentSize {
    return Size(
        fixedImgSize.width + padding * 2, fixedImgSize.height + padding * 2);
  }

  Offset rawPosition(Offset point) {
    // 转成原始的尺寸和相对位置
    XBImageEditorOperaClip? lastClipOpear = widget.operaUtil.lastClipOpear;

    Offset tl;
    Size showedImgPartSize; // 当前展示的图片的部分的原始尺寸
    if (lastClipOpear != null) {
      tl = Offset(lastClipOpear.newTL.x, lastClipOpear.newTL.y);
      showedImgPartSize = lastClipOpear.newSize;
    } else {
      tl = const Offset(0, 0);
      showedImgPartSize =
          Size(widget.image.width * 1.0, widget.image.height * 1.0);
    }
    final fixedSize = fixedImgSize;
    double xScale = showedImgPartSize.width / fixedSize.width;
    double yScale = showedImgPartSize.height / fixedSize.height;
    Offset temp = Offset(point.dx * xScale, point.dy * yScale);

    // 转成相对于图片原始尺寸的位置
    temp = Offset(temp.dx + tl.dx, temp.dy + tl.dy);
    return temp;
  }

  double get operaScale {
    final lastClipOpear = widget.operaUtil.lastClipOpear;

    /// 裁剪前的显示区域
    Size originImgSize =
        Size(widget.image.width * 1.0, widget.image.height * 1.0);
    Size originFixedSize = originImgSize;

    /// 裁剪后的显示区域
    Size newImgSize;
    if (lastClipOpear != null) {
      newImgSize = lastClipOpear.newSize;
    } else {
      newImgSize = Size(widget.image.width * 1.0, widget.image.height * 1.0);
    }
    Size newFixedSize = newImgSize;

    /// 找出x、y方向上缩放比例大的作为scale
    final xScale = newFixedSize.width / originFixedSize.width;
    final yScale = newFixedSize.height / originFixedSize.height;

    double scale = max(xScale, yScale);
    return scale;
  }

  /// 初始化时，图片的原始尺寸和真实显示大小的缩放比例
  double get initDisplayScale {
    final rawSize = Size(widget.image.width * 1.0, widget.image.height * 1.0);
    final imgDisplaySize = fixImgSize(rawSize);

    /// 找出x、y方向上缩放比例大的作为scale
    final xScale = rawSize.width / imgDisplaySize.width;
    final yScale = rawSize.height / imgDisplaySize.height;

    /// 因为是等比缩放，所以xScale和yScale事相同的
    double scale = max(xScale, yScale);
    return scale;
  }
}
