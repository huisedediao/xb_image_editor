import 'package:flutter/material.dart';

class XBImageEditorColorUtil {
  final List<Color> colors;
  final VoidCallback onChanged;
  XBImageEditorColorUtil({required this.colors, required this.onChanged});
  Color get selectedColor => colors[colorIndex];
  int _colorIndex = 4;
  int get colorIndex => _colorIndex;
  set colorIndex(int newValue) {
    _colorIndex = newValue;
    onChanged();
  }

  notify() {
    onChanged();
  }
}
