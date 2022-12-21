import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../video_uploader.dart';
import 'video_uploader_platform_interface.dart';

export 'types.dart';

/// A api.video uploader.
class ApiVideoMobileUploaderPlugin extends ApiVideoUploaderPlatform {
  static void registerWith() {
    ApiVideoUploaderPlatform.instance = ApiVideoMobileUploaderPlugin();
  }

  /// Sets [environment] API base path.
  ///
  /// By default, environment is set [Environment.production].
  @override
  void setEnvironment(Environment environment) {
    _ApiVideoMessaging().invokeMethod('setEnvironment',
        <String, dynamic>{'environment': environment.basePath});
  }

  /// Sets API key.
  ///
  /// You don't have to set an API key if you are using an upload token.
  @override
  void setApiKey(String? apiKey) {
    _ApiVideoMessaging()
        .invokeMethod('setApiKey', <String, dynamic>{'apiKey': apiKey});
  }

  /// Sets upload chunk [size].
  ///
  /// Returns the size of the chunk if it succeeded to set chunk size
  @override
  void setChunkSize(int size) async {
    int chunkSize = await _ApiVideoMessaging()
        .invokeMethod('setChunkSize', <String, dynamic>{'size': size});
    if (chunkSize != size) {
      throw Exception('Failed to set chunk size');
    }
  }

  /// Sets Application name.
  @override
  void setApplicationName(String name, String version) {
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
  @override
  Future<String> uploadWithUploadToken(
    String token,
    String filePath,
    String fileName, [
    OnProgress? onProgress,
  ]) async {
    var videoJson = await _ApiVideoMessaging().invokeMethod(
        'uploadWithUploadToken',
        <String, dynamic>{
          'token': token,
          'filePath': filePath,
        },
        onProgress);
    return videoJson;
  }

  /// Uploads [filePath] to the [videoId].
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Get upload progression with [onProgress].
  ///
  /// Alternatively for large file, you might want to use [ProgressiveUploadSession].
  @override
  Future<String> upload(String videoId, String filePath,
      [OnProgress? onProgress]) async {
    var videoJson = await _ApiVideoMessaging().invokeMethod(
        'upload',
        <String, dynamic>{'videoId': videoId, 'filePath': filePath},
        onProgress);
    return videoJson;
  }

  // Progressive upload with upload token
  /// Creates a progressive upload session for [videoId].
  @override
  void createProgressiveUploadWithUploadTokenSession(String token) {
    _ApiVideoMessaging().invokeMethod(
        'createProgressiveUploadWithUploadTokenSession',
        <String, dynamic>{'token': token});
  }

  /// Uploads a part of a large video file.
  ///
  /// Get upload progression with [onProgress].
  @override
  Future<String> uploadWithUploadTokenPart(String token, String filePath,
      [OnProgress? onProgress]) async {
    return await _ApiVideoMessaging().invokeMethod('uploadPart',
        <String, dynamic>{'token': token, 'filePath': filePath}, onProgress);
  }

  /// Uploads the last part of a large video file.
  ///
  /// Once called, you must not use this progressive upload session anymore.
  ///
  /// Get upload progression with [onProgress].
  @override
  Future<String> uploadWithUploadTokenLastPart(String token, String filePath,
      [OnProgress? onProgress]) async {
    return await _ApiVideoMessaging().invokeMethod('uploadLastPart',
        <String, dynamic>{'token': token, 'filePath': filePath}, onProgress);
  }

  // Progressive upload
  /// Creates a progressive upload session with upload [token].
  @override
  void createProgressiveUploadSession(String videoId) {
    _ApiVideoMessaging()
        .invokeMethod('createProgressiveUploadSession', <String, dynamic>{
      'videoId': videoId,
    });
  }

  /// Uploads a part of a large video file.
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Get upload progression with [onProgress].
  Future<String> uploadPart(String videoId, String filePath,
      [OnProgress? onProgress]) async {
    return await _ApiVideoMessaging().invokeMethod(
        'uploadPart',
        <String, dynamic>{'videoId': videoId, 'filePath': filePath},
        onProgress);
  }

  /// Uploads the last part of a large video file.
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Once called, you must not use this progressive upload session anymore.
  ///
  /// Get upload progression with [onProgress].
  Future<String> uploadLastPart(String videoId, String filePath,
      [OnProgress? onProgress]) async {
    return await _ApiVideoMessaging().invokeMethod(
        'uploadLastPart',
        <String, dynamic>{'videoId': videoId, 'filePath': filePath},
        onProgress);
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
