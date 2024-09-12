import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// 用assets中的图片生成ui.Image
Future<ui.Image> generateUiImgFromAssetsPath(String path) async {
  final byteData = await rootBundle.load(path);
  final Uint8List bytes = byteData.buffer.asUint8List();
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}

/// 用沙盒中的图片生成Uint8List
Future<Uint8List?> generateUint8ListFromFilePath(String path) async {
  try {
    final Uint8List data = await File(path).readAsBytes();
    if (data.isEmpty) {
      return null;
    }
    final ui.Codec codec = await ui.instantiateImageCodec(data);
    await codec.getNextFrame();
    return data;
  } catch (e) {
    return null;
  }
}

/// 用沙盒中的图片生成ui.Image
Future<ui.Image> generateUiImgFromFilePath(String path) async {
  final Uint8List data = await File(path).readAsBytes();
  final ui.Codec codec = await ui.instantiateImageCodec(data);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

/// 用Uint8List生成ui.Image
Future<ui.Image> generateUiImgFromUint8List(Uint8List data) async {
  final ui.Codec codec = await ui.instantiateImageCodec(data);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

/// 用网络图片生成ui.Image
Future<ui.Image> generateUiImgFromNet(String imageUrl) async {
  final Completer<ui.Image> completer = Completer();
  final ImageStream stream =
      Image.network(imageUrl).image.resolve(ImageConfiguration.empty);

  // 监听图片流
  final listener = ImageStreamListener(
    (ImageInfo info, bool isSync) {
      completer.complete(info.image); // 成功加载图片
    },
    onError: (exception, stackTrace) {
      completer.completeError('Failed to load image: $exception'); // 处理错误
    },
  );
  stream.addListener(listener);

  // 在完成后移除监听器
  completer.future.then((_) => stream.removeListener(listener));

  return completer.future;
}

Future<Uint8List?> convertUIImageToUint8List(ui.Image image) async {
  var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}

Future<Uint8List?> convertPainterToImage(
    CustomPainter painter, Size size) async {
  try {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    painter.paint(canvas, size);

    final picture = recorder.endRecording();
    ui.Image image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (e) {
    return null;
  }
}

String? generateBase64ImgFromUint8List(Uint8List imageBytes) {
  try {
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  } catch (e) {
    return null;
  }
}

Future<String?> generateBase64ImgFromFilePath(String imagePath) async {
  try {
    File imageFile = File(imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  } catch (e) {
    return null;
  }
}

// 将Uint8List转换为File的函数
File uint8ListToFile(Uint8List data, String path) {
  // 创建File对象
  File file = File(path);
  // 将数据写入文件
  file.writeAsBytesSync(data);
  return file;
}

Size fitSize(Size containerSize, Size imgSize, [bool fill = false]) {
  double containerWHScale = containerSize.width / containerSize.height;
  double imgWHScale = imgSize.width / imgSize.height;
  double scale;
  if (imgWHScale < containerWHScale) {
    if (fill) {
      scale = containerSize.width / imgSize.width;
    } else {
      scale = containerSize.height / imgSize.height;
    }
  } else {
    if (fill) {
      scale = containerSize.height / imgSize.height;
    } else {
      scale = containerSize.width / imgSize.width;
    }
  }
  final height = imgSize.height * scale;
  final width = imgSize.width * scale;
  return Size(width, height);
}

Size textSize(String text, TextStyle style) {
  TextSpan textSpan;
  textSpan = TextSpan(
    text: text,
    style: style,
  );
  TextPainter textPainter;
  textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  return textPainter.size;
}

Uint8List rotateImage(Uint8List imageData, double angle) {
  // 将 Uint8List 转换为 Image 对象
  img.Image? image = img.decodeImage(imageData);

  if (image == null) {
    throw Exception("无法解码图像");
  }

  // 旋转图片
  img.Image rotatedImage = img.copyRotate(image, angle: angle);

  // 将旋转后的图像转换回 Uint8List
  Uint8List rotatedData = Uint8List.fromList(img.encodePng(rotatedImage));

  return rotatedData;
}
