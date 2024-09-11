import 'package:flutter/material.dart';
import 'package:xb_scaffold/xb_scaffold.dart';
import 'xb_image_editor_config.dart';

class XBImageEditorTopBar extends StatelessWidget {
  const XBImageEditorTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: xbImgEditorColorDarkGrey,
      child: Padding(
        padding: EdgeInsets.only(top: stateBarH),
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              XBButton(
                  onTap: () {
                    Navigator.of(context, rootNavigator: false).pop();
                  },
                  coverTransparentWhileOpacity: true,
                  child: Container(
                    // color: colors.randColor,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: spaces.gapDef,
                        right: spaces.gapDef,
                      ),
                      child: Text(
                        cancelText_ ?? "取消",
                        style: TextStyle(
                            color: Colors.blue, fontSize: fontSizes.s14),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
