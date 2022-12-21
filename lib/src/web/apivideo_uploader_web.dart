import 'dart:html';
import 'dart:js_util';
import 'dart:js' as js;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../../video_uploader.dart';
import '../video_uploader_platform_interface.dart';
import 'js_controller.dart';


class ApiVideoUploaderPlugin extends ApiVideoUploaderPlatform {
  late String _apiKey;

  static void registerWith(Registrar registrar) {
    ApiVideoUploaderPlatform.instance = ApiVideoUploaderPlugin();
  }

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
  void setApiKey(String apiKey) => _apiKey = apiKey;

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
        });
        if (onProgress != null) {
          uploader.onProgress((e) => onProgress(e.uploadedBytes, e.totalBytes));
        }
        var jsonObject = await uploader.upload();
        return JSON.stringify(jsonObject);
      };
    ''';
    return await useJsScript(
      onProgress: onProgress,
      jsMethod: () => jsUploadWithApiKey(filePath, _apiKey, videoId),
      scriptContent: script,
      scriptId: 'uploadWithApiKeyScript',
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
