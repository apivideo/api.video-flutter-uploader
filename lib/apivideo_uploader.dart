import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:apivideo_uploader/types/video.dart';
import 'package:apivideo_uploader/types/environment.dart';

/// A api.video uploader.
class ApiVideoUploader {
  static const MethodChannel _channel =
      const MethodChannel('video.api/uploader');

  /// Sets [environment] API base path.
  ///
  /// By default, environment is set [Environment.production].
  static void setEnvironment(Environment environment) {
    _channel.invokeMethod('setEnvironment',
        <String, dynamic>{'environment': environment.basePath});
  }

  /// Sets API key
  ///
  /// You don't have to set an API key if you are using an upload token.
  static void setApiKey(String apiKey) {
    _channel.invokeMethod('setApiKey', <String, dynamic>{'apiKey': apiKey});
  }

  /// Uploads [filePath] with an upload [token].
  ///
  /// Alternatively for large file, you might want to use [ProgressiveUploadWithUploadTokenSession].
  static Future<Video> uploadWithUploadToken(
      String token, String filePath) async {
    var videoJson =
        await _channel.invokeMethod('uploadWithUploadToken', <String, dynamic>{
      'token': token,
      'filePath': filePath,
    });
    return Video.fromJson(jsonDecode(videoJson));
  }

  /// Uploads [filePath] to the [videoId].
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Alternatively for large file, you might want to use [ProgressiveUploadSession].
  static Future<Video> upload(String videoId, String filePath) async {
    var videoJson = await _channel.invokeMethod(
        'upload', <String, dynamic>{'videoId': videoId, 'filePath': filePath});
    return Video.fromJson(jsonDecode(videoJson));
  }

  /// Creates a progressive upload session for [videoId].
  static ProgressiveUploadSession createProgressiveUploadSession(
      String videoId) {
    return ProgressiveUploadSession(_channel, videoId);
  }

  /// Creates a progressive upload session with upload [token].
  static ProgressiveUploadWithUploadTokenSession
      createProgressiveUploadWithUploadTokenSession(String token) {
    return ProgressiveUploadWithUploadTokenSession(_channel, token);
  }
}

/// A session that manages progressive upload with upload token.
class ProgressiveUploadWithUploadTokenSession {
  /// The video token
  final String token;

  /// The [MethodChannel] to control native plugin
  final MethodChannel _channel;

  /// Creates a progressive upload with upload [token].
  ProgressiveUploadWithUploadTokenSession(this._channel, this.token) {
    _channel.invokeMethod('createUploadWithUploadTokenSession',
        <String, dynamic>{'token': token});
  }

  /// Uploads a part of a large video file.
  Future<Video> uploadPart(String filePath) async {
    var videoJson = await _channel.invokeMethod(
        'uploadPart', <String, dynamic>{'token': token, 'filePath': filePath});
    return Video.fromJson(jsonDecode(videoJson));
  }

  /// Uploads the last part of a large video file.
  ///
  /// Once called, you must not use this progressive upload session anymore.
  Future<Video> uploadLastPart(String filePath) async {
    var videoJson = await _channel.invokeMethod('uploadLastPart',
        <String, dynamic>{'token': token, 'filePath': filePath});
    return Video.fromJson(jsonDecode(videoJson));
  }
}

/// A session that manages progressive upload.
class ProgressiveUploadSession {
  /// The video identifier.
  final String videoId;

  /// The [MethodChannel] to control native plugin.
  final MethodChannel _channel;

  /// Creates a progressive upload for [videoId].
  ProgressiveUploadSession(this._channel, this.videoId) {
    _channel.invokeMethod(
        'createUploadSession', <String, dynamic>{'videoId': videoId});
  }

  /// Uploads a part of a large video file.
  ///
  /// You have to set the API key with [setApiKey] before.
  Future<Video> uploadPart(String filePath) async {
    var videoJson = await _channel.invokeMethod('uploadPart',
        <String, dynamic>{'videoId': videoId, 'filePath': filePath});
    return Video.fromJson(jsonDecode(videoJson));
  }

  /// Uploads the last part of a large video file.
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Once called, you must not use this progressive upload session anymore.
  Future<Video> uploadLastPart(String filePath) async {
    var videoJson = await _channel.invokeMethod('uploadLastPart',
        <String, dynamic>{'videoId': videoId, 'filePath': filePath});
    return Video.fromJson(jsonDecode(videoJson));
  }
}
