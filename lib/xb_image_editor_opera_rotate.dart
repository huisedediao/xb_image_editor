import 'xb_image_editor_config.dart';
import 'xb_image_editor_opera.dart';

class XBImageEditorOperaRotate extends XBImageEditorOpera {
  /// 旋转了多少度
  final XBImageEditorOperaRotateEnum rotate;

  XBImageEditorOperaRotate({required this.rotate});

  @override
  XBImageEditorOpera deepCopy() {
    return XBImageEditorOperaRotate(rotate: rotate);
  }
}
