import 'dart:html';
import 'dart:js_util';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:video_uploader/src/web/js_controller.dart';

class ApiVideoUploaderPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'video.api/uploader',
      const StandardMethodCodec(),
      registrar.messenger,
    );
    final ApiVideoUploaderPlugin instance = ApiVideoUploaderPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'uploadWithUploadToken':
        final String? token = call.arguments['token'];
        final String? filePath = call.arguments['filePath'];
        ArgumentError.checkNotNull(token, 'upload token');
        ArgumentError.checkNotNull(filePath, 'file path');
        return uploadWithUploadToken(token!, filePath!);
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The ApiVideoUploader plugin for web doesn't implement "
              "the method '${call.method}'",
        );
    }
  }

  Future<String> uploadWithUploadToken(String token, String filePath) async {
    ScriptElement script = ScriptElement()
      ..innerText = '''
      window.uploadWithUploadToken = async function(filePath, token) {
        var blob = await fetch(filePath)
          .then(r => {
            let header = r.headers.get('Content-Disposition');
            console.log(header);
            return r.blob();
          });
        var jsonObject = await new VideoUploader({
            file: blob,
            uploadToken: token,
        })
        .upload();
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
    final String json =
        await promiseToFuture<String>(jsUploadWithUploadToken(filePath, token));
    document.body!.querySelector('#uploadWithUploadTokenScript')!.remove();
    return json;
  }
}
