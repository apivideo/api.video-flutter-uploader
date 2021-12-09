import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class ApiVideoUploader {
  static const MethodChannel _channel = const MethodChannel('video.api/uploader');

  static Future<Map<String, dynamic>?> uploadVideo(
      String token, String fileName, String filePath) async {
    Map<String, dynamic>? json;
    var video = await _channel.invokeMethod('uploadVideo', <String, dynamic>{
      'token': token,
      'fileName': fileName,
      'filePath': filePath,
    });
    json = jsonDecode(video);
    return json;
  }
}
