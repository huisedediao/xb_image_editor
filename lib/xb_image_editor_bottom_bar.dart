import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xb_scaffold/xb_scaffold.dart';
import 'xb_image_editor_config.dart';

class XBImageEditorBottomBar extends StatelessWidget {
  final bool isCanPrevious;
  final int selectedOperaIndex;
  final ValueChanged<int> onOperaChanged;
  final String brTitle;
  final VoidCallback onPrevious;
  final VoidCallback onClean;
  final VoidCallback onTapBr;
  final List<XBImageEditorOperaType>? needOperaTypes;
  const XBImageEditorBottomBar(
      {required this.isCanPrevious,
      required this.selectedOperaIndex,
      required this.onOperaChanged,
      required this.onPrevious,
      required this.onClean,
      required this.brTitle,
      required this.onTapBr,
      this.needOperaTypes,
      super.key});

  @override
  Widget build(BuildContext context) {
    final needOperaTypesTemp = needOperaTypes ??
        [
          XBImageEditorOperaType.pen,
          XBImageEditorOperaType.mosaic,
          XBImageEditorOperaType.clip,
          XBImageEditorOperaType.text
        ];
    return Container(
      color: xbImageEditorColorBlack,
      child: Padding(
        padding: EdgeInsets.only(bottom: safeAreaBottom),
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                    child: generateBtn(isCanPrevious,
                        onTap: onPrevious,
                        imgSel:
                            "packages/xb_image_editor/assets/images/previous_step_blue.png",
                        imgNor:
                            "packages/xb_image_editor/assets/images/previous_step_grey.png",
                        imgW: 27),
                  ),
                  Expanded(
                    child: generateBtn(isCanPrevious,
                        onTap: onClean,
                        imgSel:
                            "packages/xb_image_editor/assets/images/edit_clear_blue.png",
                        imgNor:
                            "packages/xb_image_editor/assets/images/edit_clear_grey.png",
                        imgW: 22),
                  ),
                  Visibility(
                    visible:
                        needOperaTypesTemp.contains(XBImageEditorOperaType.pen),
                    child: Expanded(
                      child: generateBtn(selectedOperaIndex == 0, onTap: () {
                        onOperaChanged(0);
                      },
                          imgSel:
                              "packages/xb_image_editor/assets/images/edit_pen_blue.png",
                          imgNor:
                              "packages/xb_image_editor/assets/images/edit_pen_white.png",
                          imgW: 20),
                    ),
                  ),
                  Visibility(
                    visible: needOperaTypesTemp
                        .contains(XBImageEditorOperaType.mosaic),
                    child: Expanded(
                      child: generateBtn(selectedOperaIndex == 1, onTap: () {
                        onOperaChanged(1);
                      },
                          imgSel:
                              "packages/xb_image_editor/assets/images/edit_mosaic_blue.png",
                          imgNor:
                              "packages/xb_image_editor/assets/images/edit_mosaic_white.png",
                          imgW: 20),
                    ),
                  ),
                  Visibility(
                      visible: needOperaTypesTemp
                          .contains(XBImageEditorOperaType.clip),
                      child: Expanded(
                        child: generateBtn(selectedOperaIndex == 2, onTap: () {
                          onOperaChanged(2);
                        },
                            imgSel:
                                "packages/xb_image_editor/assets/images/edit_clip_blue.png",
                            imgNor:
                                "packages/xb_image_editor/assets/images/edit_clip_white.png",
                            imgW: 20),
                      )),
                  Visibility(
                      visible: needOperaTypesTemp
                          .contains(XBImageEditorOperaType.text),
                      child: Expanded(
                        child: generateBtn(selectedOperaIndex == 3, onTap: () {
                          onOperaChanged(3);
                        },
                            imgSel:
                                "packages/xb_image_editor/assets/images/edit_text_blue.png",
                            imgNor:
                                "packages/xb_image_editor/assets/images/edit_text_white.png",
                            imgW: 20),
                      )),
                ],
              )),
              XBButton(
                  onTap: onTapBr,
                  coverTransparentWhileOpacity: true,
                  child: Container(
                    // color: colors.randColor,
                    alignment: Alignment.center,
                    width: 65,
                    child: Text(brTitle,
                        style: TextStyle(
                            color: Colors.blue, fontSize: fontSizes.s14)),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget generateIcon(
    bool isSelected, {
    required String imgSel,
    required String imgNor,
    double imgW = 30,
  }) {
    double topPadding = (50 - imgW) * 0.5;
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: topPadding),
      child: XBImage(
        isInPackage: true,
        isSelected ? imgSel : imgNor,
        width: imgW,
      ),
    );
  }

  XBButton generateBtn(
    bool isSelected, {
    required String imgSel,
    required String imgNor,
    required VoidCallback onTap,
    double imgW = 30,
  }) {
    return XBButton(
        onTap: onTap,
        coverTransparentWhileOpacity: true,
        child: generateIcon(isSelected,
            imgSel: imgSel, imgNor: imgNor, imgW: imgW));
  }
}
