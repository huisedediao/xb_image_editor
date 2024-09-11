import 'package:flutter/material.dart';
import 'package:xb_scaffold/xb_scaffold.dart';

class XBImageEditorColorSelector extends StatelessWidget {
  final List<Color> colors;
  final ValueChanged<int> onIndexChanged;
  final int selectedIndex;
  const XBImageEditorColorSelector(
      {required this.colors,
      required this.selectedIndex,
      required this.onIndexChanged,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(colors.length, (index) {
        return XBButton(
            onTap: () {
              onIndexChanged(index);
            },
            coverTransparentWhileOpacity: true,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(w(index == selectedIndex) * 0.5),
                child: Container(
                  width: w(index == selectedIndex),
                  height: w(index == selectedIndex),
                  color: colors[index],
                ),
              ),
            ));
      }),
    );
  }

  double w(bool isSelected) => isSelected ? 18 : 10;
}
