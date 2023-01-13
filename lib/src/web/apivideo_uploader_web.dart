import 'dart:html';
import 'dart:js_util';
import 'dart:js' as js;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../../video_uploader.dart';
import '../video_uploader_platform_interface.dart';
import 'js_controller.dart';

class ApiVideoUploaderPlugin extends ApiVideoUploaderPlatform {
  late String _apiKey;
  int _chunkSize = 50;

  static void registerWith(Registrar registrar) {
    ApiVideoUploaderPlatform.instance = ApiVideoUploaderPlugin();
  }

  @override
  void setApiKey(String apiKey) => _apiKey = apiKey;

  @override
  void setChunkSize(int size) => _chunkSize = size;

  @override
  Future<String> uploadWithUploadToken(
    String token,
    String filePath,
    String fileName, [
    OnProgress? onProgress,
  ]) async {
    final String script = '''
      window.uploadWithUploadToken = async function(filePath, token, fileName) {
        var blob = await fetch(filePath)
          .then(r => r.blob());
        var uploader = new VideoUploader({
            file: blob,
            uploadToken: token,
            videoName: fileName,
            chunkSize: 1024*1024*$_chunkSize,
            origin: { sdk: { name: 'flutter-uploader', version: '1.0.0', }, },
        });
        if (onProgress != null) {
          uploader.onProgress((e) => onProgress(e.uploadedBytes, e.totalBytes));
        }
        var jsonObject = await uploader.upload();
        return JSON.stringify(jsonObject);
      };
    ''';
    return await useJsScript<String>(
      onProgress: onProgress,
      jsMethod: () => jsUploadWithUploadToken(filePath, token, fileName),
      scriptContent: script,
      scriptId: 'uploadWithUploadTokenScript',
    );
  }

  @override
  Future<String> upload(String videoId, String filePath,
      [OnProgress? onProgress]) async {
    final String script = '''
      window.uploadWithApiKey = async function(filePath, apiKey, videoId) {
        var blob = await fetch(filePath)
          .then(r => r.blob());
        var uploader = new VideoUploader({
            file: blob,
            apiKey,
            videoId,
            chunkSize: $_chunkSize,
            origin: { sdk: { name: 'flutter-uploader', version: '1.0.0', }, },
        });
        if (onProgress != null) {
          uploader.onProgress((e) => onProgress(e.uploadedBytes, e.totalBytes));
        }
        var jsonObject = await uploader.upload();
        return JSON.stringify(jsonObject);
      };
    ''';
    return await useJsScript<String>(
      onProgress: onProgress,
      jsMethod: () => jsUploadWithApiKey(filePath, _apiKey, videoId),
      scriptContent: script,
      scriptId: 'uploadWithApiKeyScript',
    );
  }

  @override
  void createProgressiveUploadWithUploadTokenSession(String token) {
    if (document.querySelector('#progressiveUploadTokenScript') == null) {
      final ScriptElement script = ScriptElement()
        ..innerText = '''
          window.progressiveUploaderToken = new ProgressiveUploader({
            uploadToken: "$token",
            origin: { sdk: { name: 'flutter-uploader', version: '1.0.0', }, },
          });
        '''
        ..id = 'progressiveUploadTokenScript';
      document.body?.insertAdjacentElement('beforeend', script);
    }
  }

  @override
  Future<String> uploadWithUploadTokenPart(String token, String filePath,
      [OnProgress? onProgress]) async {
    final String script = '''
      window.progressiveUploadWithUploadToken = async function(filePath) {
        var blob = await fetch(filePath)
          .then(r => r.blob());
        if (onProgress != null) {
          window.progressiveUploaderToken.onProgress((e) => onProgress(e.uploadedBytes, e.totalBytes));
        }
        await window.progressiveUploaderToken.uploadPart(blob);
        return '';
      }
    ''';
    return await useJsScript<String>(
      onProgress: onProgress,
      jsMethod: () => jsProgressiveUploadWithToken(filePath),
      scriptContent: script,
      scriptId: 'progressiveUploadWithTokenScript',
    );
  }

  @override
  Future<String> uploadWithUploadTokenLastPart(String token, String filePath,
      [OnProgress? onProgress]) async {
    final String script = '''
      window.progressiveUploadWithUploadToken = async function(filePath) {
        var blob = await fetch(filePath)
          .then(r => r.blob());
        if (onProgress != null) {
          window.progressiveUploaderToken.onProgress((e) => onProgress(e.uploadedBytes, e.totalBytes));
        }
        var jsonObject = await window.progressiveUploaderToken.uploadLastPart(blob);
        return JSON.stringify(jsonObject);
      }
    ''';
    return await useJsScript<String>(
      onProgress: onProgress,
      jsMethod: () => jsProgressiveUploadWithToken(filePath),
      scriptContent: script,
      scriptId: 'progressiveUploadWithTokenScript',
    );
  }

  dynamic useJsScript<T>({
    OnProgress? onProgress,
    required Function jsMethod,
    required String scriptContent,
    required String scriptId,
  }) async {
    if (onProgress != null)
      js.context['onProgress'] = js.allowInterop(onProgress);
    else
      js.context['onProgress'] = null;

    final ScriptElement script = ScriptElement()
      ..innerText = scriptContent
      ..id = scriptId;
    if (document.body == null) {
      throw Exception(
        'No body tag found in the DOM: try to add a body tag to the DOM and retry.',
      );
    }
    document.body!.insertAdjacentElement('beforeend', script);
    final res = await promiseToFuture<T>(jsMethod());
    document.body!.querySelector('#$scriptId')!.remove();
    return res;
  }
}
