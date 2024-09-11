import 'package:flutter/material.dart';
import 'package:xb_scaffold/xb_scaffold.dart';

class XBImageEditorWidth extends StatelessWidget {
  final List<double> widths;
  final ValueChanged<int> onWidthChanged;
  final int selectedIndex;
  const XBImageEditorWidth(
      {required this.widths,
      required this.selectedIndex,
      required this.onWidthChanged,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widths.length, (index) {
        final w = widths[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: XBButton(
            onTap: () {
              onWidthChanged(index);
            },
            coverTransparentWhileOpacity: true,
            child: XBBG(
              color: Colors.transparent,
              borderColor: Colors.white,
              borderWidth: onePixel,
              defAllRadius: w * 0.5 + onePixel,
              paddingH: 0,
              paddingV: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(w * 0.5),
                child: Container(
                  width: w,
                  height: w,
                  color: selectedIndex == index
                      ? Colors.white
                      : Colors.transparent,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
