import 'package:flutter/material.dart';

class XBImageEditorMosaicWidthUtil {
  List<double> get mosaicWidths => [10, 14, 18, 22, 26, 30];
  final VoidCallback onChanged;
  XBImageEditorMosaicWidthUtil({required this.onChanged});
  double get selectedMosaicWidth => mosaicWidths[mosaicWidthIndex];
  int _mosaicWidthIndex = 0;
  int get mosaicWidthIndex => _mosaicWidthIndex;
  set mosaicWidthIndex(int newValue) {
    _mosaicWidthIndex = newValue;
    onChanged();
  }

  notify() {
    onChanged();
  }
}
