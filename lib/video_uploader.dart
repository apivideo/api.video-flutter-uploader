import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_uploader/src/api_video_uploader_platform_interface.dart';

import 'src/types/environment.dart';
import 'src/types/video.dart';
export 'src/video_uploader_mobile_platform.dart';

export 'src/types.dart';

/// Progress indicator callback
typedef void OnProgress(int bytesSent, int totalBytes);

ApiVideoUploaderPlatform get _uploaderPlatform {
  return ApiVideoUploaderPlatform.instance;
}

/// A api.video uploader.
class ApiVideoUploader {
  /// Sets [environment] API base path.
  ///
  /// By default, environment is set [Environment.production].
  static void setEnvironment(Environment environment) {
    _ApiVideoMessaging().invokeMethod('setEnvironment',
        <String, dynamic>{'environment': environment.basePath});
  }

  /// Sets API key.
  ///
  /// You don't have to set an API key if you are using an upload token.
  static void setApiKey(String apiKey) {
    return _uploaderPlatform.setApiKey(apiKey);
  }

  /// Sets upload chunk [size].
  ///
  /// Returns the size of the chunk if it succeeded to set chunk size
  static Future<int> setChunkSize(int size) async {
    return await _ApiVideoMessaging()
        .invokeMethod('setChunkSize', <String, dynamic>{'size': size});
  }

  /// Sets Application name.
  static void setApplicationName(String name, String version) {
    _ApiVideoMessaging().invokeMethod('setApplicationName',
        <String, dynamic>{'name': name, 'version': version});
  }

  /// Uploads [filePath] with an upload [token].
  ///
  /// Get upload progression with [onProgress].
  ///
  /// For web usage only, you can provide a custom [fileName] to your uploaded video.
  /// Default is "uploaded_file".
  ///
  /// Alternatively for large file, you might want to use [ProgressiveUploadWithUploadTokenSession].
  static Future<Video> uploadWithUploadToken(
    String token,
    String filePath, [
    OnProgress? onProgress,
    String fileName = 'file',
  ]) async {
    return Video.fromJson(jsonDecode(await _uploaderPlatform
        .uploadWithUploadToken(token, filePath, fileName, onProgress)));
  }

  /// Uploads [filePath] to the [videoId].
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Get upload progression with [onProgress].
  ///
  /// Alternatively for large file, you might want to use [ProgressiveUploadSession].
  static Future<Video> upload(String videoId, String filePath,
      [OnProgress? onProgress, String fileName = 'file']) async {
    return Video.fromJson(jsonDecode(await _uploaderPlatform.upload(
        videoId, filePath, fileName, onProgress)));
  }

  /// Creates a progressive upload session for [videoId].
  static ProgressiveUploadSession createProgressiveUploadSession(
      String videoId) {
    return ProgressiveUploadSession(videoId);
  }

  /// Creates a progressive upload session with upload [token].
  static ProgressiveUploadWithUploadTokenSession
      createProgressiveUploadWithUploadTokenSession(String token) {
    return ProgressiveUploadWithUploadTokenSession(token);
  }
}

/// A session that manages progressive upload with upload token.
class ProgressiveUploadWithUploadTokenSession {
  /// The video token
  final String token;

  /// Creates a progressive upload with upload [token].
  ProgressiveUploadWithUploadTokenSession(this.token) {
    _ApiVideoMessaging().invokeMethod('createUploadWithUploadTokenSession',
        <String, dynamic>{'token': token});
  }

  /// Uploads a part of a large video file.
  ///
  /// Get upload progression with [onProgress].
  Future<Video> uploadPart(String filePath, [OnProgress? onProgress]) async {
    var videoJson = await _ApiVideoMessaging().invokeMethod('uploadPart',
        <String, dynamic>{'token': token, 'filePath': filePath}, onProgress);
    return Video.fromJson(jsonDecode(videoJson));
  }

  /// Uploads the last part of a large video file.
  ///
  /// Once called, you must not use this progressive upload session anymore.
  ///
  /// Get upload progression with [onProgress].
  Future<Video> uploadLastPart(String filePath,
      [OnProgress? onProgress]) async {
    var videoJson = await _ApiVideoMessaging().invokeMethod('uploadLastPart',
        <String, dynamic>{'token': token, 'filePath': filePath}, onProgress);
    return Video.fromJson(jsonDecode(videoJson));
  }
}

/// A session that manages progressive upload.
class ProgressiveUploadSession {
  /// The video identifier.
  final String videoId;

  /// Creates a progressive upload for [videoId].
  ProgressiveUploadSession(this.videoId) {
    _ApiVideoMessaging().invokeMethod(
        'createUploadSession', <String, dynamic>{'videoId': videoId});
  }

  /// Uploads a part of a large video file.
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Get upload progression with [onProgress].
  Future<Video> uploadPart(String filePath, [OnProgress? onProgress]) async {
    var videoJson = await _ApiVideoMessaging().invokeMethod(
        'uploadPart',
        <String, dynamic>{'videoId': videoId, 'filePath': filePath},
        onProgress);
    return Video.fromJson(jsonDecode(videoJson));
  }

  /// Uploads the last part of a large video file.
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Once called, you must not use this progressive upload session anymore.
  ///
  /// Get upload progression with [onProgress].
  Future<Video> uploadLastPart(String filePath,
      [OnProgress? onProgress]) async {
    var videoJson = await _ApiVideoMessaging().invokeMethod(
        'uploadLastPart',
        <String, dynamic>{'videoId': videoId, 'filePath': filePath},
        onProgress);
    return Video.fromJson(jsonDecode(videoJson));
  }
}

/// A singleton that manages communication between dart and native
class _ApiVideoMessaging {
  /// The communication channel
  final MethodChannel _channel = const MethodChannel('video.api/uploader');

  /// The map between id and progress callback
  final _onProgressMap = Map<String, OnProgress?>();
  static final _ApiVideoMessaging _apiVideoMessaging =
      _ApiVideoMessaging._internal();

  factory _ApiVideoMessaging() {
    return _apiVideoMessaging;
  }

  _ApiVideoMessaging._internal() {
    _setMethodCallHandler();
  }

  /// Registers method call handler to intercep messages from native parts
  void _setMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onProgress":
          final String id = call.arguments["operationId"];
          if (_onProgressMap[id] != null) {
            final int bytesSent = call.arguments["bytesSent"];
            final int totalBytes = call.arguments["totalBytes"];
            _onProgressMap[id]!(bytesSent, totalBytes);
          }
          break;
      }
      return;
    });
  }

  /// Register a [onProgress] listener in [OnProgress] indicator callback list
  String _addProgressCallback(OnProgress? onProgress) {
    final id = UniqueKey().toString();
    _onProgressMap[id] = onProgress;
    return id;
  }

  /// Unregister a listener named [id] in the onProgress indicator callback list
  void _removeProgressCallback(String id) {
    _onProgressMap.remove(id);
  }

  /// Invokes a [method] on api.video uploader channel with the specified
  /// [arguments].
  Future<T?> invokeMethod<T>(String method,
      [dynamic arguments, OnProgress? onProgress]) async {
    String operationId = _addProgressCallback(onProgress);
    arguments["operationId"] = operationId;
    final result = await _channel.invokeMethod<T>(method, arguments);
    _removeProgressCallback(operationId);
    return result;
  }
}
