import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../video_uploader.dart';

abstract class ApiVideoUploaderPlatform extends PlatformInterface {
  /// Constructs a ApiVideoUploaderPlatform.
  ApiVideoUploaderPlatform() : super(token: _token);

  static final Object _token = Object();

  final String sdkVersion = '1.0.0';

  static ApiVideoUploaderPlatform _instance = _PlatformImplementation();

  /// The default instance of [ApiVideoUploaderPlatform] to use.
  ///
  /// Defaults to [_PlatformImplementation].
  static ApiVideoUploaderPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ApiVideoUploaderPlatform] when
  /// they register themselves.
  static set instance(ApiVideoUploaderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void setEnvironment(Environment environment) {
    throw UnimplementedError('setEnvironment() has not been implemented.');
  }

  void setApiKey(String apiKey) {
    throw UnimplementedError('setApiKey() has not been implemented.');
  }

  void setChunkSize(int size) {
    throw UnimplementedError('setChunkSize() has not been implemented.');
  }

  void setApplicationName(String name, String version) {
    throw UnimplementedError('setApplicationName() has not been implemented.');
  }

  void setTimeout(int timeout) {
    throw UnimplementedError('setTimeout() has not been implemented.');
  }

  Future<String> uploadWithUploadToken(
    String token,
    String filePath,
    String fileName, [
    OnProgress? onProgress,
  ]) {
    throw UnimplementedError(
      'uploadWithUploadToken() has not been implemented.',
    );
  }

  Future<String> upload(String videoId, String filePath,
      [OnProgress? onProgress]) {
    throw UnimplementedError('upload() has not been implemented.');
  }

  // Progressive upload with upload token
  void createProgressiveUploadWithUploadTokenSession(String token) {
    throw UnimplementedError(
      'createProgressiveUploadSession() has not been implemented.',
    );
  }

  Future<String> uploadWithUploadTokenPart(String token, String filePath,
      [OnProgress? onProgress]) {
    throw UnimplementedError('uploadPart() has not been implemented.');
  }

  Future<String> uploadWithUploadTokenLastPart(String token, String filePath,
      [OnProgress? onProgress]) {
    throw UnimplementedError('uploadLastPart() has not been implemented.');
  }

  // Progressive upload
  void createProgressiveUploadSession(String videoId) {
    throw UnimplementedError(
      'createProgressiveUploadSession() has not been implemented.',
    );
  }

  Future<String> uploadPart(String videoId, String filePath,
      [OnProgress? onProgress]) {
    throw UnimplementedError('uploadPart() has not been implemented.');
  }

  Future<String> uploadLastPart(String videoId, String filePath,
      [OnProgress? onProgress]) {
    throw UnimplementedError('uploadLastPart() has not been implemented.');
  }
}

class _PlatformImplementation extends ApiVideoUploaderPlatform {}
