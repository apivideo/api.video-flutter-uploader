import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../video_uploader.dart';
import 'video_uploader_platform_interface.dart';

export 'types.dart';

/// A api.video uploader.
class ApiVideoMobileUploaderPlugin extends ApiVideoUploaderPlatform {
  /// The communication channel
  final MethodChannel _channel = const MethodChannel('video.api.uploader');
  late final _UploadChannel _uploadChannel =
      _UploadChannel(_channel, sdkVersion);

  static void registerWith() {
    ApiVideoUploaderPlatform.instance = ApiVideoMobileUploaderPlugin();
  }

  /// Sets [environment] API base path.
  ///
  /// By default, environment is set [Environment.production].
  @override
  void setEnvironment(Environment environment) {
    _channel.invokeMethod('setEnvironment',
        <String, dynamic>{'environment': environment.basePath});
  }

  /// Sets API key.
  ///
  /// You don't have to set an API key if you are using an upload token.
  @override
  void setApiKey(String? apiKey) {
    _channel.invokeMethod('setApiKey', <String, dynamic>{'apiKey': apiKey});
  }

  /// Sets upload chunk [size].
  ///
  /// Returns the size of the chunk if it succeeded to set chunk size
  @override
  void setChunkSize(int size) async {
    int chunkSize = await _channel
        .invokeMethod('setChunkSize', <String, dynamic>{'size': size});
    if (chunkSize != size) {
      throw Exception('Failed to set chunk size');
    }
  }

  /// Sets the [timeout] in milliseconds.
  @override
  void setTimeout(int timeout) {
    _channel.invokeMethod('setTimeout', <String, dynamic>{'timeout': timeout});
  }

  /// Sets Application name.
  @override
  void setApplicationName(String name, String version) {
    _channel.invokeMethod('setApplicationName',
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
    String fileName,
    String? videoId, [
    OnProgress? onProgress,
  ]) async {
    var videoJson = await _uploadChannel.invokeMethod(
        'uploadWithUploadToken',
        <String, dynamic>{
          'token': token,
          'filePath': filePath,
          'videoId': videoId,
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
    var videoJson = await _uploadChannel.invokeMethod(
        'upload',
        <String, dynamic>{'videoId': videoId, 'filePath': filePath},
        onProgress);
    return videoJson;
  }

  // Progressive upload with upload token
  /// Creates a progressive upload session for [videoId].
  @override
  void createProgressiveUploadWithUploadTokenSession(
      String sessionId, String token, String? videoId) {
    _channel.invokeMethod(
        'createProgressiveUploadWithUploadTokenSession', <String, dynamic>{
      'sessionId': sessionId,
      'token': token,
      'videoId': videoId
    });
  }

  /// Uploads a part of a large video file.
  ///
  /// Get upload progression with [onProgress].
  @override
  Future<String> uploadWithUploadTokenPart(String sessionId, String filePath,
      [OnProgress? onProgress]) async {
    return await _uploadChannel.invokeMethod(
        'uploadPart',
        <String, dynamic>{'sessionId': sessionId, 'filePath': filePath},
        onProgress);
  }

  /// Uploads the last part of a large video file.
  ///
  /// Once called, you must not use this progressive upload session anymore.
  ///
  /// Get upload progression with [onProgress].
  @override
  Future<String> uploadWithUploadTokenLastPart(
      String sessionId, String filePath,
      [OnProgress? onProgress]) async {
    return await _uploadChannel.invokeMethod(
        'uploadLastPart',
        <String, dynamic>{'sessionId': sessionId, 'filePath': filePath},
        onProgress);
  }

  // Progressive upload
  /// Creates a progressive upload session with upload [token].
  @override
  void createProgressiveUploadSession(String sessionId, String videoId) {
    _channel.invokeMethod('createProgressiveUploadSession', <String, dynamic>{
      'sessionId': sessionId,
      'videoId': videoId,
    });
  }

  /// Uploads a part of a large video file.
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Get upload progression with [onProgress].
  Future<String> uploadPart(String sessionId, String filePath,
      [OnProgress? onProgress]) async {
    return await _uploadChannel.invokeMethod(
        'uploadPart',
        <String, dynamic>{'sessionId': sessionId, 'filePath': filePath},
        onProgress);
  }

  /// Uploads the last part of a large video file.
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Once called, you must not use this progressive upload session anymore.
  ///
  /// Get upload progression with [onProgress].
  Future<String> uploadLastPart(String sessionId, String filePath,
      [OnProgress? onProgress]) async {
    return await _uploadChannel.invokeMethod(
        'uploadLastPart',
        <String, dynamic>{'sessionId': sessionId, 'filePath': filePath},
        onProgress);
  }

  /// Cleans up the resources associated with this session.
  void disposeProgressiveUploadSession(String sessionId) {
    _channel.invokeMethod('disposeProgressiveUploadSession',
        <String, dynamic>{'sessionId': sessionId});
  }

  /// Cancels all the uploads.
  Future<void> cancelAll() async {
    await _channel.invokeMethod('cancelAll');
  }
}

/// A wrapper around upload calls to manage progress callback.
class _UploadChannel {
  /// The communication channel
  final MethodChannel _channel;
  final String _sdkVersion;

  /// The uploader events channel
  final eventChannel = const EventChannel('video.api.uploader/events');

  _UploadChannel(this._channel, this._sdkVersion) {
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  /// The map between id and progress callback
  final _onProgressMap = Map<String, OnProgress?>();

  /// Sets SDK [version] and name
  ///
  /// This method must be called before any other method.
  /// It is meant to be internal.
  Future<void> _setSdkVersion(String version) async {
    return _channel.invokeMethod('setSdkNameVersion',
        <String, dynamic>{'version': version, 'name': 'flutter-uploader'});
  }

  /// Registers method call handler to intercept messages from native parts
  void _onEvent(dynamic event) {
    if (event["type"] == "progressChanged") {
      final String id = event["uploadId"];
      if (_onProgressMap[id] != null) {
        final double progress = event["progress"];
        _onProgressMap[id]!(progress);
      }
    } else {
      print("Unknown event type: ${event["type"]}");
    }
  }

  void _onError(Object error) {
    print('upload error: $error');
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

  /// Invokes a [method] with [OnProgress] callback with the specified
  /// [arguments].
  Future<T?> invokeMethod<T>(String method,
      [dynamic arguments, OnProgress? onProgress]) async {
    await _setSdkVersion(_sdkVersion);

    String uploadId = _addProgressCallback(onProgress);
    arguments["uploadId"] = uploadId;
    final result = await _channel.invokeMethod<T>(method, arguments);
    _removeProgressCallback(uploadId);
    return result;
  }
}

class UploaderEvent {
  /// Adds optional parameters here if needed
  final Object? data;

  /// The [LiveStreamingEventType]
  final UploaderEventType type;

  UploaderEvent({required this.type, this.data});
}

enum UploaderEventType {
  /// The upload progress has changed.
  progressChanged
}
