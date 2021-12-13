import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:apivideo_uploader/types/video.dart';

class ApiVideoUploader {
  static const MethodChannel _channel =
      const MethodChannel('video.api/uploader');

  static Future<Video> uploadVideo(
      String token, String filePath) async {
    var videoJson =
        await _channel.invokeMethod('uploadWithUploadToken', <String, dynamic>{
      'token': token,
      'filePath': filePath,
    });
    return Video.fromJson(jsonDecode(videoJson));
  }
}
