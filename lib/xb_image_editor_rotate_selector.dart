import 'package:flutter/material.dart';
import 'package:xb_scaffold/xb_scaffold.dart';

class XBImageEditorRotateSelector extends StatelessWidget {
  /// 0逆时针，1顺时针
  final ValueChanged<int> onRotateChanged;
  const XBImageEditorRotateSelector({required this.onRotateChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        XBButton(
            onTap: () {
              onRotateChanged(0);
            },
            coverTransparentWhileOpacity: true,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: XBImage(
                isInPackage: true,
                "packages/xb_image_editor/assets/images/edit_rotate_left.png",
                width: 27,
              ),
            )),
        const SizedBox(
          width: 40,
        ),
        XBButton(
            onTap: () {
              onRotateChanged(1);
            },
            coverTransparentWhileOpacity: true,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: XBImage(
                isInPackage: true,
                "packages/xb_image_editor/assets/images/edit_rotate_right.png",
                width: 27,
              ),
            )),
      ],
    );
  }
}
