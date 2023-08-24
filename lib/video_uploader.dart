import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'src/types/environment.dart';
import 'src/types/video.dart';
import 'src/video_uploader_platform_interface.dart';

export 'src/types.dart';
export 'src/video_uploader_mobile_platform.dart';

/// Progress indicator callback
/// [progress] is a value between 0 and 100
typedef void OnProgress(int progress);

ApiVideoUploaderPlatform get _uploaderPlatform {
  return ApiVideoUploaderPlatform.instance;
}

/// A api.video uploader.
class ApiVideoUploader {
  /// Sets [environment] API base path.
  ///
  /// By default, environment is set [Environment.production].
  static void setEnvironment(Environment environment) {
    return _uploaderPlatform.setEnvironment(environment);
  }

  /// Sets API key.
  ///
  /// You don't have to set an API key if you are using an upload token.
  static void setApiKey(String apiKey) {
    return _uploaderPlatform.setApiKey(apiKey);
  }

  /// Sets upload chunk [size].
  ///
  /// Throws an exception if it failed to set chunk size.
  static void setChunkSize(int size) async {
    return _uploaderPlatform.setChunkSize(size);
  }

  /// Sets Application [name] and [version].
  static void setApplicationName(String name, String version) {
    return _uploaderPlatform.setApplicationName(name, version);
  }

  /// Sets the request [timeout] in milliseconds.
  static void setTimeout(int timeout) {
    return _uploaderPlatform.setTimeout(timeout);
  }

  /// Uploads [filePath] with an upload [token] and optionally [videoId].
  ///
  /// Get upload progression with [onProgress].
  ///
  /// For web usage only, you can provide a custom [fileName] to your uploaded video.
  /// Default is "uploaded_file".
  ///
  /// Alternatively for large file, you might want to use [ProgressiveUploadWithUploadTokenSession].
  static Future<Video> uploadWithUploadToken(
    String token,
    String filePath, {
    String? videoId,
    OnProgress? onProgress,
    String fileName = 'file',
  }) async {
    return Video.fromJson(jsonDecode(
        await _uploaderPlatform.uploadWithUploadToken(
            token, filePath, fileName, videoId, onProgress)));
  }

  /// Uploads [filePath] to the [videoId].
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Get upload progression with [onProgress].
  ///
  /// Alternatively for large file, you might want to use [ProgressiveUploadSession].
  static Future<Video> upload(String videoId, String filePath,
      {OnProgress? onProgress}) async {
    return Video.fromJson(jsonDecode(
        await _uploaderPlatform.upload(videoId, filePath, onProgress)));
  }

  /// Creates a progressive upload session for [videoId].
  static ProgressiveUploadSession createProgressiveUploadSession(
      String videoId) {
    return ProgressiveUploadSession(videoId);
  }

  /// Creates a progressive upload session with upload [token].
  static ProgressiveUploadWithUploadTokenSession
      createProgressiveUploadWithUploadTokenSession(String token,
          {String? videoId}) {
    return ProgressiveUploadWithUploadTokenSession(token, videoId);
  }

  /// Cancels all uploads.
  static cancelAll() {
    return _uploaderPlatform.cancelAll();
  }
}

/// A session that manages progressive upload with upload token.
class ProgressiveUploadWithUploadTokenSession {
  /// A unique identifier for the upload session.
  final String _sessionId = UniqueKey().toString();

  /// The video token
  final String token;

  /// The video id.
  final String? videoId;

  /// Creates a progressive upload with upload [token].
  ProgressiveUploadWithUploadTokenSession(this.token, this.videoId) {
    _uploaderPlatform.createProgressiveUploadWithUploadTokenSession(
        _sessionId, token, videoId);
  }

  /// Uploads a part of a large video file.
  ///
  /// Get upload progression with [onProgress].
  Future<dynamic> uploadPart(String filePath, {OnProgress? onProgress}) async {
    if (kIsWeb) {
      return _uploaderPlatform.uploadWithUploadTokenPart(
          token, filePath, onProgress);
    }
    return Video.fromJson(jsonDecode(await _uploaderPlatform
        .uploadWithUploadTokenPart(_sessionId, filePath, onProgress)));
  }

  /// Uploads the last part of a large video file.
  ///
  /// Once called, you must not use this progressive upload session anymore.
  ///
  /// Get upload progression with [onProgress].
  Future<Video> uploadLastPart(String filePath,
      {OnProgress? onProgress}) async {
    return Video.fromJson(jsonDecode(await _uploaderPlatform
        .uploadWithUploadTokenLastPart(_sessionId, filePath, onProgress)));
  }

  /// Cleans up the resources associated with this session.
  void dispose() {
    _uploaderPlatform.disposeProgressiveUploadSession(_sessionId);
  }
}

/// A session that manages progressive upload.
class ProgressiveUploadSession {
  /// A unique identifier for the upload session.
  final String _sessionId = UniqueKey().toString();

  /// The video identifier.
  final String videoId;

  /// Creates a progressive upload for [videoId].
  ProgressiveUploadSession(this.videoId) {
    _uploaderPlatform.createProgressiveUploadSession(_sessionId, videoId);
  }

  /// Uploads a part of a large video file.
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Get upload progression with [onProgress].
  Future<dynamic> uploadPart(String filePath, {OnProgress? onProgress}) async {
    if (kIsWeb) {
      return _uploaderPlatform.uploadPart(_sessionId, filePath, onProgress);
    }
    return Video.fromJson(jsonDecode(
        await _uploaderPlatform.uploadPart(_sessionId, filePath, onProgress)));
  }

  /// Uploads the last part of a large video file.
  ///
  /// You have to set the API key with [setApiKey] before.
  ///
  /// Once called, you must not use this progressive upload session anymore.
  ///
  /// Get upload progression with [onProgress].
  Future<Video> uploadLastPart(String filePath,
      {OnProgress? onProgress}) async {
    return Video.fromJson(jsonDecode(await _uploaderPlatform.uploadLastPart(
        _sessionId, filePath, onProgress)));
  }

  /// Cleans up the resources associated with this session.
  void dispose() {
    _uploaderPlatform.disposeProgressiveUploadSession(_sessionId);
  }
}
