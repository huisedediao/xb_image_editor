import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xb_image_editor/xb_image_editor.dart';
import 'package:xb_scaffold/xb_scaffold.dart';

class XBImageEditorTest extends XBPage<XBImageEditorTestVM> {
  const XBImageEditorTest({super.key});

  @override
  generateVM(BuildContext context) {
    return XBImageEditorTestVM(context: context);
  }

  @override
  Widget buildPage(XBImageEditorTestVM vm, BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
              child: XBImage(
            vm.imgData ?? vm.imgPath,
            fit: BoxFit.contain,
          )),
          XBButton(
            onTap: () async {
              final ret = await Navigator.push(
                  context,
                  CupertinoPageRoute<XBImageEditorRet?>(
                      settings: null,
                      builder: (context) => XBImageEditor(
                            img: vm.imgPath,
                            initOperas: vm.operas,
                            cancelText: "cancel",
                            completeText: "complete",
                            confirmText: "confirm",
                            clipText: "clip",
                            inputTextTip: "type text",
                            newText: "tap to change",
                          )));

              if (ret != null) {
                vm.imgData = ret.imgData;
                vm.operas = ret.operas;
                vm.notify();
              }
            },
            coverTransparentWhileOpacity: true,
            child: Container(
              height: 50,
              color: Colors.blue,
              alignment: Alignment.center,
              child: const Text(
                "编辑图片",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class XBImageEditorTestVM extends XBPageVM<XBImageEditorTest> {
  XBImageEditorTestVM({required super.context});

  // final String imgPath = "assets/images/test6.jpg";
  final String imgPath = "assets/images/function_bg.png";

  List<XBImageEditorOpera> operas = [];

  Uint8List? imgData;

  @override
  void back<O extends Object?>([O? result]) {
    Navigator.of(context, rootNavigator: false).pop(result);
  }
}
