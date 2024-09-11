import 'dart:math';
import 'package:flutter/material.dart';
import 'model/xb_image_editor_clip_mask_change_info.dart';
import 'xb_image_editor_opera.dart';

class XBImageEditorOperaClip extends XBImageEditorOpera {
  /// 左上和右下的坐标
  /// 这个坐标，是以图片的原始尺寸为坐标系
  /// 直接表示在原始图片的位置，不需要再计算
  List<Point<double>> get tlbr {
    return [newTL, Point(newTL.x + newSize.width, newTL.y + newSize.height)];
  }

  Point<double> get newTL {
    return Point(clipInfo.model.points![0].x! * xRDScale + referenceTL.x,
        clipInfo.model.points![0].y! * yRDScale + referenceTL.y);
  }

  Size get newSize {
    final w = clipInfo.model.points![1].x! - clipInfo.model.points![0].x!;
    final h = clipInfo.model.points![2].y! - clipInfo.model.points![1].y!;
    return Size(w * xRDScale, h * yRDScale);
  }

  /// 参考的起始点
  final Point<double> referenceTL;

  /// 参考的尺寸
  final Size referenceSize;

  final XBImageEditorClipMaskChangeInfo clipInfo;

  double get xRDScale => referenceSize.width / clipInfo.displaySize.width;
  double get yRDScale => referenceSize.height / clipInfo.displaySize.height;

  XBImageEditorOperaClip({
    required this.clipInfo,
    required this.referenceTL,
    required this.referenceSize,
  });

  @override
  XBImageEditorOpera deepCopy() {
    return XBImageEditorOperaClip(
      clipInfo: clipInfo,
      referenceTL: referenceTL,
      referenceSize: referenceSize,
    );
  }
}
