import 'dart:html';
import 'dart:js_util';
import 'dart:js' as js;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:video_uploader/src/web/js_controller.dart';

class ApiVideoUploaderPlugin {
  static MethodChannel? channel;
  static void registerWith(Registrar registrar) {
    channel = MethodChannel(
      'video.api/uploader',
      const StandardMethodCodec(),
      registrar.messenger,
    );
    final ApiVideoUploaderPlugin instance = ApiVideoUploaderPlugin();
    channel!.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'uploadWithUploadToken':
        final String token = call.arguments['token'];
        final String filePath = call.arguments['filePath'];
        final String operationId = call.arguments['operationId'];
        print(call.arguments);
        ArgumentError.checkNotNull(token, 'upload token');
        ArgumentError.checkNotNull(filePath, 'file path');
        return uploadWithUploadToken(token, filePath, operationId);
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The ApiVideoUploader plugin for web doesn't implement "
              "the method '${call.method}'",
        );
    }
  }

  Future<String> uploadWithUploadToken(
    String token,
    String filePath,
    String operationId,
  ) async {
    if (channel == null) {
      throw Exception('Method channel for web platform is null');
    }
    js.context['manageUploadProgress'] = js.allowInterop(_manageUploadProgress);
    ScriptElement script = ScriptElement()
      ..innerText = '''
      window.uploadWithUploadToken = async function(filePath, token, operationId) {
        var blob = await fetch(filePath)
          .then(r => r.blob());
        var uploader = new VideoUploader({
            file: blob,
            uploadToken: token,
        });
        uploader.onProgress((e) => manageUploadProgress(operationId, e.uploadedBytes, e.totalBytes));
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
        operationId,
      ),
    );
    document.body!.querySelector('#uploadWithUploadTokenScript')!.remove();
    return json;
  }

  void _manageUploadProgress(
    String operationId,
    int completedUnitCount,
    int totalUnitCount,
  ) {
    channel!.invokeMethod(
      "onProgress",
      {
        "operationId": operationId,
        "bytesSent": completedUnitCount,
        "totalBytes": totalUnitCount,
      },
    );
  }
}
