/*
Type：Line 添加线，Rect 添加矩形， Area：添加多边形
RGBA：R,G,B,透明度
ABType:针对直线，0是起点到终点的法线正向表示A，1是起点到终点的法线反向表示A
{
    "cmd": "RoiAdd",
    "contents": {
        "Type": "Line",
"ABType": 1,
"Name": "#1",
        "ID": 1,
        "RGBA": [
            255,
            0,
            255,
            100
        ]
    }
}
*/

// import 'package:bcloud/utils/print_util.dart';
import 'package:flutter/material.dart';
import 'package:xb_scaffold/xb_scaffold.dart';

/// 一个model就表示一个area
class XBImageEditorGraphModel {
  static const defRgba = [22, 119, 255, 50];

  static const String typeLine = "Line";
  static const String typeRect = "Rect";
  static const String typeArea = "Area";

  static const int abTypeDef = 0;
  static const int abTypeArrow = 3;

  // static int _nextId = 0;
  static int get getId {
    // int tempId = _nextId;
    // _nextId++;
    // return tempId;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  static String getName(String? type) {
    if (type == typeLine) {
      return "#Line";
    }
    if (type == typeRect) {
      return "#Rect";
    }
    if (type == typeArea) {
      return "#Area";
    }
    return "XBGraphModel";
  }

  /// 存储本地的点
  List<XBImageEditorGraphModelPoints>? points;
  int? abType;
  int? id;
  String? name;
  String? customName;
  List<int>? rgba;
  String? type;
  double? lineWidth;

  XBImageEditorGraphModel(
      {this.points,
      this.abType,
      this.id,
      this.name,
      this.customName,
      this.rgba,
      this.type,
      this.lineWidth});

  /// 只用于从服务端获取的数据转模型
  XBImageEditorGraphModel.fromJson(
      {required Map<String, dynamic> json,
      required Size displaySize,
      required Size rawSize}) {
    final tempPoints = json['points'];
    if (tempPoints != null && tempPoints is List) {
      points = <XBImageEditorGraphModelPoints>[];
      for (var v in tempPoints) {
        points!.add(XBImageEditorGraphModelPoints(
            x: (xbParse<double>(v['X']) ?? 0) /
                rawSize.width *
                displaySize.width,
            y: (xbParse<double>(v['Y']) ?? 0) /
                rawSize.height *
                displaySize.height));
      }
    }
    abType = xbParse<int>(json['abType']);
    id = xbParse<int>(json['id']);
    name = xbParse<String>(json['name']);
    rgba = xbParseList<int>(json['rgba']);
    if (rgba == null || rgba!.isEmpty) {
      rgba = defRgba;
    }
    type = xbParse<String>(json['type']);
  }

  bool isAllPointInBoundsAfterOffset(
      Offset offset, double minX, double maxX, double minY, double maxY) {
    if (points == null || points!.isEmpty) {
      return false;
    }
    bool ret = true;
    for (var element in points!) {
      if (element.x! + offset.dx < minX ||
          element.x! + offset.dx > maxX ||
          element.y! + offset.dy < minY ||
          element.y! + offset.dy > maxY) {
        ret = false;
        break;
      }
    }
    return ret;
  }

  /// points 中的点必须是按照多边形的边界顺序排列的
  /// 判断点是不是在points组成的多边形内部
  bool isPointInsidePolygon(double pointX, double pointY) {
    if (points == null || points!.isEmpty) return false;

    bool isInside = false;
    for (int i = 0, j = points!.length - 1; i < points!.length; j = i++) {
      if (((points![i].y! > pointY) != (points![j].y! > pointY)) &&
          (pointX <
              (points![j].x! - points![i].x!) *
                      (pointY - points![i].y!) /
                      (points![j].y! - points![i].y!) +
                  points![i].x!)) {
        isInside = !isInside;
      }
    }
    return isInside;
  }

  void translatePoints(Offset offset) {
    // Console.error(offset);
    if (points == null || points!.isEmpty) return;
    for (var point in points!) {
      // Console.error("old point.x::${point.x}");
      point.x = point.x! + offset.dx;
      point.y = point.y! + offset.dy;
      // Console.error("new point.x::${point.x}");
    }
  }

  void translatePointsAutoFix(
      Offset offset, double minX, double maxX, double minY, double maxY) {
    if (points == null || points!.isEmpty) return;
    final first = points!.first;
    final second = points![1];
    final fouth = points![3];

    bool needMoveX =
        !(first.x! + offset.dx < minX || second.x! + offset.dx > maxX);
    bool needMoveY =
        !(first.y! + offset.dy < minY || fouth.y! + offset.dy > maxY);
    for (var point in points!) {
      if (needMoveX) {
        point.x = point.x! + offset.dx;
      }
      if (needMoveY) {
        point.y = point.y! + offset.dy;
      }
    }
  }

  bool isDistanceGreaterThanRadiusToAll(double touchX, double touchY) {
    if (points == null || points!.isEmpty) return true;
    for (var element in points!) {
      if (!element.isSelected &&
          !element.isDistanceGreaterThanRadius(
              XBImageEditorGraphModelPoints(x: touchX, y: touchY))) {
        return false;
      }
    }
    return true;
  }

  XBImageEditorGraphModelPoints? findInsidePoint(double touchX, double touchY) {
    if (points == null || points!.isEmpty) return null;
    for (var element in points!) {
      if (element.isInside(touchX, touchY)) {
        return element;
      }
    }
    return null;
  }

  XBImageEditorGraphModelPoints? findSelectedPoint() {
    for (XBImageEditorGraphModelPoints element in points ?? []) {
      if (element.isSelected) {
        return element;
      }
    }
    return null;
  }
}

/// 存储本地的点
class XBImageEditorGraphModelPoints {
  double? x;
  double? y;

  final int radius = 30;

  bool isSelected = false;

  XBImageEditorGraphModelPoints({this.x, this.y});

  bool isInside(double touchX, double touchY) {
    double dx = touchX - (x ?? 0);
    double dy = touchY - (y ?? 0);
    return (dx * dx + dy * dy) <= (radius * radius);
  }

  bool isInActionArea(
      double touchX, double touchY, double xOffset, double yOffset) {
    double dx = touchX - ((x ?? 0) + xOffset);
    double dy = touchY - ((y ?? 0) + yOffset);
    return (dx * dx + dy * dy) <= (radius * radius);
  }

  bool isDistanceGreaterThanRadius(XBImageEditorGraphModelPoints other) =>
      !isInside((other.x ?? 0).toDouble(), (other.y ?? 0).toDouble());
}
