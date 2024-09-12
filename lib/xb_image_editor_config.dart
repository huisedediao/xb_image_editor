import 'package:flutter/material.dart';

const Color xbImageEditorColorBlack = Colors.black;
const Color xbImageEditorColorDarkGrey = Color.fromARGB(255, 25, 24, 24);

enum XBImageEditorOperaRotateEnum {
  raw,
  clockwise,
  anticlockwise,
}

enum XBImageEditorOperaType {
  pen,
  mosaic,
  clip,
  text,
}

String? inputTextTip_;
String? newText_;
String? cancelText_;
String? confirmText_;
String? completeText_;
String? clipText_;
