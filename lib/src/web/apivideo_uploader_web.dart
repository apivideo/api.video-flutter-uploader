// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:html';
import 'dart:js' as js;
import 'dart:js_util';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../../video_uploader.dart';
import '../video_uploader_platform_interface.dart';
import 'js_controller.dart';

class ApiVideoUploaderPlugin extends ApiVideoUploaderPlatform {
  late String _apiKey;

  static void registerWith(Registrar registrar) {
    ApiVideoUploaderPlatform.instance = ApiVideoUploaderPlugin();
  }

  ApiVideoUploaderPlugin() {
    injectJS();
  }

  Future<void> injectJS() async {
    document.body?.nodes.add(ScriptElement()
      ..type = 'text/javascript'
      ..src = '/packages/video_uploader/assets/uploader.js'
      ..addEventListener('load', (event) {
        // Fix Require.js issues with Flutter overrides
        // https://github.com/flutter/flutter/issues/126713
        js.context.callMethod('fixRequireJs', []);

        document.body!.append(ScriptElement()
          ..type = 'text/javascript'
          ..innerText = '''window.apiVideoFlutterUploader = { 
                      params: {
                        sdkVersion: '$sdkVersion',
                        chunkSize: 50,
                      }
                    }''');

        document.body!.append(ScriptElement()
          ..src = 'https://unpkg.com/@api.video/video-uploader'
          ..type = 'application/javascript');
      }));
  }

  @override
  void setApiKey(String apiKey) => _apiKey = apiKey;

  @override
  void setApplicationName(String name, String version) {
    jsSetApplicationName(name, version);
  }

  @override
  void setChunkSize(int size) {
    jsSetChunkSize(size);
  }

  // standard upload with upload token
  @override
  Future<String> uploadWithUploadToken(
    String token,
    String filePath,
    String fileName,
    String? videoId, [
    OnProgress? onProgress,
  ]) async {
    return await promiseToFuture(jsUploadWithUploadToken(
        filePath,
        token,
        fileName,
        onProgress != null ? js.allowInterop(onProgress) : null,
        videoId));
  }

  // standard upload with api key
  @override
  Future<String> upload(String videoId, String filePath,
      [OnProgress? onProgress]) async {
    return await promiseToFuture(jsUploadWithApiKey(filePath, _apiKey,
        onProgress != null ? js.allowInterop(onProgress) : null, videoId));
  }

  // progressive upload with upload token
  @override
  void createProgressiveUploadWithUploadTokenSession(
      String sessionId, String token, String? videoId) {
    jsCreateProgressiveUploadWithUploadTokenSession(sessionId, token, videoId);
  }

  @override
  Future<String> uploadWithUploadTokenPart(String sessionId, String filePath,
      [OnProgress? onProgress]) async {
    return await promiseToFuture(jsUploadWithUploadTokenPart(sessionId,
        filePath, onProgress != null ? js.allowInterop(onProgress) : null));
  }

  @override
  Future<String> uploadWithUploadTokenLastPart(
      String sessionId, String filePath,
      [OnProgress? onProgress]) async {
    return await promiseToFuture(jsUploadWithUploadTokenLastPart(sessionId,
        filePath, onProgress != null ? js.allowInterop(onProgress) : null));
  }

  // progressive upload with api key
  @override
  void createProgressiveUploadSession(String sessionId, String videoId) {
    jsCreateProgressiveUploadWithApiKeySession(sessionId, _apiKey, videoId);
  }

  @override
  Future<String> uploadPart(String sessionId, String filePath,
      [OnProgress? onProgress]) async {
    return await promiseToFuture(jsUploadWithUploadTokenPart(sessionId,
        filePath, onProgress != null ? js.allowInterop(onProgress) : null));
  }

  @override
  Future<String> uploadLastPart(String sessionId, String filePath,
      [OnProgress? onProgress]) async {
    return await promiseToFuture(jsUploadWithUploadTokenLastPart(sessionId,
        filePath, onProgress != null ? js.allowInterop(onProgress) : null));
  }
}

class ApplicationName {
  ApplicationName({
    required this.name,
    required this.version,
  });

  String name;
  String version;
}
