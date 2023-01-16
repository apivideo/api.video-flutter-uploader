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
  int _chunkSize = 50;
  ApplicationName? _applicationName;

  static void registerWith(Registrar registrar) {
    ApiVideoUploaderPlatform.instance = ApiVideoUploaderPlugin();
  }

  @override
  void setApiKey(String apiKey) => _apiKey = apiKey;

  @override
  void setApplicationName(String name, String version) =>
      _applicationName = ApplicationName(name: name, version: version);

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
            origin: {
              sdk: { name: 'flutter-uploader', version: '1.0.0', },
              ${_applicationName != null ? "application: { name: '${_applicationName!.name}', version: '${_applicationName!.version}', }," : ""}
            },
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
            origin: {
              sdk: { name: 'flutter-uploader', version: '1.0.0', },
              ${_applicationName != null ? "application: { name: '${_applicationName!.name}', version: '${_applicationName!.version}', }," : ""}
            },
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
    final ScriptElement script = ScriptElement()
      ..innerText = '''
        window.progressiveUploaderToken = new ProgressiveUploader({
          uploadToken: "$token",
          origin: {
            sdk: { name: 'flutter-uploader', version: '1.0.0', },
            ${_applicationName != null ? "application: { name: '${_applicationName!.name}', version: '${_applicationName!.version}', }," : ""}
          },
        });
      '''
      ..id = 'progressiveUploadTokenScript';
    document.body?.insertAdjacentElement('beforeend', script);
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

  @override
  void createProgressiveUploadSession(String videoId) {
    final ScriptElement script = ScriptElement()
      ..innerText = '''
        window.progressiveUploaderAK = new ProgressiveUploader({
          videoId: "$videoId",
          apiKey: "$_apiKey",
          origin: {
            sdk: { name: 'flutter-uploader', version: '1.0.0', },
            ${_applicationName != null ? "application: { name: '${_applicationName!.name}', version: '${_applicationName!.version}', }," : ""}
          },
        });
      '''
      ..id = 'progressiveUploadAKScript';
    document.body?.insertAdjacentElement('beforeend', script);
  }

  @override
  Future<String> uploadPart(String videoId, String filePath,
      [OnProgress? onProgress]) async {
    final String script = '''
      window.progressiveUploadWithApiKey = async function(filePath) {
        var blob = await fetch(filePath)
          .then(r => r.blob());
        if (onProgress != null) {
          window.progressiveUploaderAK.onProgress((e) => onProgress(e.uploadedBytes, e.totalBytes));
        }
        await window.progressiveUploaderAK.uploadPart(blob);
        return '';
      }
    ''';
    return await useJsScript<String>(
      onProgress: onProgress,
      jsMethod: () => jsProgressiveUploadWithApiKey(filePath),
      scriptContent: script,
      scriptId: 'progressiveUploadWithApiKey',
    );
  }

  @override
  Future<String> uploadLastPart(String videoId, String filePath,
      [OnProgress? onProgress]) async {
    final String script = '''
      window.progressiveUploadWithApiKey = async function(filePath) {
        var blob = await fetch(filePath)
          .then(r => r.blob());
        if (onProgress != null) {
          window.progressiveUploaderAK.onProgress((e) => onProgress(e.uploadedBytes, e.totalBytes));
        }
        var jsonObject = await window.progressiveUploaderAK.uploadLastPart(blob);
        return JSON.stringify(jsonObject);
      }
    ''';
    return await useJsScript<String>(
      onProgress: onProgress,
      jsMethod: () => jsProgressiveUploadWithApiKey(filePath),
      scriptContent: script,
      scriptId: 'progressiveUploadWithApiKey',
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

class ApplicationName {
  ApplicationName({
    required this.name,
    required this.version,
  });
  String name;
  String version;
}
