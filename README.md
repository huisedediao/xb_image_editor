# xb_image_editor
纯flutter写的图片编辑


### 安装
```
flutter pub add xb_image_editor
```

### 使用
```
            Uint8List? imgData; 
            List<XBImageEditorOpera> operas = [];

            final ret = await Navigator.push(
                context,
                CupertinoPageRoute<XBImageEditorRet?>(
                    settings: null,
                    builder: (context) => XBImageEditor(
                          img: "assets/images/function_bg.png",
                          initOperas: operas,
                        )));

            if (ret != null) {
              imgData = ret.imgData;
              operas = ret.operas;
            }
```