import 'dart:typed_data';
import 'package:xb_scaffold/xb_scaffold.dart';
import 'package:flutter/material.dart';
import 'xb_image_editor_bottom_bar.dart';
import 'xb_image_editor_config.dart';
import 'xb_image_editor_content.dart';
import 'xb_image_editor_opear_bar.dart';
import 'xb_image_editor_opera.dart';
import 'xb_image_editor_top_bar.dart';
import 'xb_image_editor_vm.dart';
export 'xb_image_editor_opera.dart';

class XBImageEditorRet {
  /// 编辑后的图片
  Uint8List imgData;

  /// 所有操作
  List<XBImageEditorOpera> operas;

  XBImageEditorRet({required this.imgData, required this.operas});
}

class XBImageEditor extends XBPage<XBImageEditorVM> {
  final dynamic img;
  final List<XBImageEditorOpera>? initOperas;
  final String? inputTextTip;
  final String? newText;
  final String? cancelText;
  final String? confirmText;
  final String? completeText;
  final String? clipText;
  const XBImageEditor(
      {required this.img,
      this.initOperas,
      this.inputTextTip,
      this.newText,
      this.cancelText,
      this.confirmText,
      this.completeText,
      this.clipText,
      super.key});

  @override
  generateVM(BuildContext context) {
    return XBImageEditorVM(context: context);
  }

  @override
  bool needShowContentFromScreenTop(XBImageEditorVM vm) {
    return true;
  }

  @override
  bool needIosGestureBack(XBImageEditorVM vm) {
    return false;
  }

  @override
  bool onAndroidPhysicalBack(XBImageEditorVM vm) {
    return false;
  }

  @override
  Widget buildPage(XBImageEditorVM vm, BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ClipRRect(
        child: Container(
          color: xbImageEditorColorDarkGrey,
          child: Column(
            children: [
              const XBImageEditorTopBar(),
              Expanded(
                  child: XBImageEditorContent(
                key: ValueKey(vm.contentKey),
                operaType: vm.operaType,
                onAreaChanged: vm.onAreaChanged,
                operaUtil: vm.operaUtil,
                penColorUtil: vm.penColorUtil,
                image: vm.image,
                mosaicWidthUtil: vm.mosaicWidthUtil,
                textColorUtil: vm.textColorUtil,
              )),
              XBImageEditorOperaBar(
                onRotateChanged: vm.onRotateChanged,
                penColorUtil: vm.penColorUtil,
                operaIndex: vm.operaType.index,
                mosaicWidthUtil: vm.mosaicWidthUtil,
                textColorUtil: vm.textColorUtil,
              ),
              XBImageEditorBottomBar(
                  onPrevious: vm.onPrevious,
                  isCanPrevious: vm.operas.isNotEmpty,
                  selectedOperaIndex: vm.operaType.index,
                  brTitle: vm.brTitle,
                  onTapBr: vm.onTapBr,
                  onOperaChanged: (index) {
                    vm.operaType = XBImageEditorOperaType.values[index];
                  })
            ],
          ),
        ),
      ),
    );
  }
}
