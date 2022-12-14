import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:video_uploader/src/video_uploader_mobile_platform.dart';

abstract class ApiVideoUploaderPlatform extends PlatformInterface {
  /// Constructs a ApiVideoUploaderPlatform.
  ApiVideoUploaderPlatform() : super(token: _token);

  static final Object _token = Object();

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

  void setApiKey(String? apiKey) {
    throw UnimplementedError('setApiKey() has not been implemented.');
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
}

class _PlatformImplementation extends ApiVideoUploaderPlatform {}
