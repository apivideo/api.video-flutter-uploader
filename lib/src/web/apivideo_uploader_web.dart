import 'dart:html';
import 'dart:js_util';
import 'dart:js' as js;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:video_uploader/src/api_video_uploader_platform_interface.dart';
import 'package:video_uploader/src/video_uploader_mobile_platform.dart';
import 'package:video_uploader/src/web/js_controller.dart';

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
    if (onProgress != null)
      js.context['onProgress'] = js.allowInterop(onProgress);
    else
      js.context['onProgress'] = null;

    ScriptElement script = ScriptElement()
      ..innerText = '''
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
    '''
      ..id = 'uploadWithUploadTokenScript';
    script.innerHtml = script.innerHtml?.replaceAll('<br>', '');
    if (document.body == null) {
      throw Exception(
        'No body tag found in the DOM: try to add a body tag to the DOM and retry.',
      );
    }
    document.body!.insertAdjacentElement('beforeend', script);
    final String json = await promiseToFuture<String>(
      jsUploadWithUploadToken(
        filePath,
        token,
        fileName,
      ),
    );
    document.body!.querySelector('#uploadWithUploadTokenScript')!.remove();
    return json;
  }

  @override
  void setApiKey(String? apiKey) {
    ArgumentError.checkNotNull(apiKey, 'api key');
    print(apiKey);
  }
}
