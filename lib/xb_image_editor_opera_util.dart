import 'dart:math';
import 'package:flutter/material.dart';
import 'xb_image_editor_config.dart';
import 'xb_image_editor_opera.dart';
import 'xb_image_editor_opera_clip.dart';
import 'xb_image_editor_opera_mosaic.dart';
import 'xb_image_editor_opera_pen.dart';
import 'xb_image_editor_opera_rotate.dart';
import 'xb_image_editor_opera_text.dart';

class XBImageEditorOperaUtil {
  final VoidCallback onChanged;
  XBImageEditorOperaUtil({required this.onChanged});
  List<XBImageEditorOpera> operas = [];

  XBImageEditorOperaClip? get lastClipOpear {
    for (int i = operas.length - 1; i >= 0; i--) {
      final temp = operas[i];
      if (temp is XBImageEditorOperaClip) {
        return temp;
      }
    }
    return null;
  }

  XBImageEditorOperaPen? get lastPenOpear {
    for (int i = operas.length - 1; i >= 0; i--) {
      final temp = operas[i];
      if (temp is XBImageEditorOperaPen) {
        return temp;
      }
    }
    return null;
  }

  XBImageEditorOperaMosaic? get lastMosaicOpear {
    for (int i = operas.length - 1; i >= 0; i--) {
      final temp = operas[i];
      if (temp is XBImageEditorOperaMosaic) {
        return temp;
      }
    }
    return null;
  }

  XBImageEditorOperaText? get lastTextOpear {
    for (int i = operas.length - 1; i >= 0; i--) {
      final temp = operas[i];
      if (temp is XBImageEditorOperaText) {
        return temp;
      }
    }
    return null;
  }

  XBImageEditorOperaText? get selectedTextOpear {
    for (int i = operas.length - 1; i >= 0; i--) {
      final temp = operas[i];
      if (temp is XBImageEditorOperaText && temp.isSelected) {
        return temp;
      }
    }
    return null;
  }

  XBImageEditorOperaText? get tapingTextOpear {
    for (int i = operas.length - 1; i >= 0; i--) {
      final temp = operas[i];
      if (temp is XBImageEditorOperaText && temp.isTaping) {
        return temp;
      }
    }
    return null;
  }

  XBImageEditorOperaText? get tapingEditTextOpear {
    for (int i = operas.length - 1; i >= 0; i--) {
      final temp = operas[i];
      if (temp is XBImageEditorOperaText && temp.isTapingEdit) {
        return temp;
      }
    }
    return null;
  }

  void unSelectedAllTextOpera() {
    for (var element in operas) {
      if (element is XBImageEditorOperaText) {
        element.isSelected = false;
      }
    }
  }

  void unTapingAllTextOpera() {
    for (var element in operas) {
      if (element is XBImageEditorOperaText) {
        element.isTaping = false;
      }
    }
  }

  void unTapingEditAllTextOpera() {
    for (var element in operas) {
      if (element is XBImageEditorOperaText) {
        element.isTapingEdit = false;
      }
    }
  }

  bool get isV => calculateRotate % 2 == 0;

  /// 大于0，逆时针
  /// 小于0，顺时针
  int get calculateRotate {
    /// 遍历，找出所有旋转操作
    /// 计算最后旋转的个数
    /// 计算角度

    /// 顺时针个数
    int clockwiseCount = 0;

    /// 逆时针个数
    int anticlockwiseCount = 0;
    for (var element in operas) {
      if (element is XBImageEditorOperaRotate) {
        if (element.rotate == XBImageEditorOperaRotateEnum.clockwise) {
          clockwiseCount++;
        } else if (element.rotate ==
            XBImageEditorOperaRotateEnum.anticlockwise) {
          anticlockwiseCount++;
        }
      }
    }
    int dif = anticlockwiseCount - clockwiseCount;
    return dif;
  }

  /// 弧度
  double get radians {
    return degreesToRadians(angle);
  }

  /// 角度
  double get angle {
    return -(calculateRotate % 4) * 90;
  }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  add(XBImageEditorOpera opera) {
    operas.add(opera);
  }

  delete(XBImageEditorOpera opera) {
    operas.remove(opera);
  }

  notify() {
    onChanged();
  }
}
