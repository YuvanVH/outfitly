import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Komprimerar en bildfil till JPEG, max 800x800 px och kvalitet 70.
/// Returnerar en [Uint8List] redo för uppladdning till Firebase Storage.
Future<Uint8List> compressImage(File file) async {
  final result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 800,
    minHeight: 800,
    quality: 70,
    format: CompressFormat.jpeg,
  );
  if (result == null) {
    throw Exception('Image compression failed');
  }
  return result;
}

/// Komprimerar en bild från bytes (t.ex. web) till JPEG, max 800x800 px och kvalitet 70.
Future<Uint8List> compressImageBytes(Uint8List bytes) async {
  final result = await FlutterImageCompress.compressWithList(
    bytes,
    minWidth: 800,
    minHeight: 800,
    quality: 70,
    format: CompressFormat.jpeg,
  );
  return result;
}
