import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:apivideo_uploader/types/video.dart';
import 'package:apivideo_uploader/types/environment.dart';

class ApiVideoUploader {
  static const MethodChannel _channel =
      const MethodChannel('video.api/uploader');

  static Future<Video> uploadWithUploadToken(
      String token, String filePath) async {
    var videoJson =
        await _channel.invokeMethod('uploadWithUploadToken', <String, dynamic>{
      'token': token,
      'filePath': filePath,
    });
    return Video.fromJson(jsonDecode(videoJson));
  }

  static Future<Video> upload(
      String videoId, String filePath) async {
    var videoJson =
    await _channel.invokeMethod('upload', <String, dynamic>{
      'videoId': videoId,
      'filePath': filePath
    });
    return Video.fromJson(jsonDecode(videoJson));
  }

  static void setEnvironment(Environment environment) {
    _channel.invokeMethod('setEnvironment',
        <String, dynamic>{'environment': environment.name});
  }

  static void setApiKey(String apiKey) {
    _channel.invokeMethod('setApiKey', <String, dynamic>{'apiKey': apiKey});
  }
}
