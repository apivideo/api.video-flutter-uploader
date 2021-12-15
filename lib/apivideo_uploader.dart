import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:apivideo_uploader/types/video.dart';
import 'package:apivideo_uploader/types/environment.dart';

class ApiVideoUploader {
  static const MethodChannel _channel =
      const MethodChannel('video.api/uploader');

  static void setEnvironment(Environment environment) {
    _channel.invokeMethod(
        'setEnvironment', <String, dynamic>{'environment': environment.name});
  }

  static void setApiKey(String apiKey) {
    _channel.invokeMethod('setApiKey', <String, dynamic>{'apiKey': apiKey});
  }

  static Future<Video> uploadWithUploadToken(
      String token, String filePath) async {
    var videoJson =
        await _channel.invokeMethod('uploadWithUploadToken', <String, dynamic>{
      'token': token,
      'filePath': filePath,
    });
    return Video.fromJson(jsonDecode(videoJson));
  }

  static Future<Video> upload(String videoId, String filePath) async {
    var videoJson = await _channel.invokeMethod(
        'upload', <String, dynamic>{'videoId': videoId, 'filePath': filePath});
    return Video.fromJson(jsonDecode(videoJson));
  }

  static ProgressiveUploadSession createProgressiveUploadSession(
      String videoId) {
    return ProgressiveUploadSession(_channel, videoId);
  }

  static ProgressiveUploadWithUploadTokenSession
      createProgressiveUploadWithUploadTokenSession(String token) {
    return ProgressiveUploadWithUploadTokenSession(_channel, token);
  }
}

class ProgressiveUploadWithUploadTokenSession {
  final String token;
  final MethodChannel _channel;

  ProgressiveUploadWithUploadTokenSession(this._channel, this.token) {
    _channel.invokeMethod('createUploadWithUploadTokenSession',
        <String, dynamic>{'token': token});
  }

  Future<Video> uploadPart(String filePath) async {
    var videoJson = await _channel.invokeMethod(
        'uploadPart', <String, dynamic>{'token': token, 'filePath': filePath});
    return Video.fromJson(jsonDecode(videoJson));
  }

  Future<Video> uploadLastPart(String filePath) async {
    var videoJson = await _channel.invokeMethod('uploadLastPart',
        <String, dynamic>{'token': token, 'filePath': filePath});
    return Video.fromJson(jsonDecode(videoJson));
  }
}

class ProgressiveUploadSession {
  final String videoId;
  final MethodChannel _channel;

  ProgressiveUploadSession(this._channel, this.videoId) {
    _channel.invokeMethod(
        'createUploadSession', <String, dynamic>{'videoId': videoId});
  }

  Future<Video> uploadPart(String filePath) async {
    var videoJson = await _channel.invokeMethod('uploadPart',
        <String, dynamic>{'videoId': videoId, 'filePath': filePath});
    return Video.fromJson(jsonDecode(videoJson));
  }

  Future<Video> uploadLastPart(String filePath) async {
    var videoJson = await _channel.invokeMethod('uploadLastPart',
        <String, dynamic>{'videoId': videoId, 'filePath': filePath});
    return Video.fromJson(jsonDecode(videoJson));
  }
}
