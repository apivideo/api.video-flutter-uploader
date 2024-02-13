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
      ..innerHtml = '''
        // fix JS module loading - https://github.com/flutter/flutter/issues/126713
        if (typeof window.define == 'function') {
          delete window.define.amd;
          delete window.exports;
          delete window.module;
        }
        window.apiVideoGetBlobFromPath = async (filePath) =>  await fetch(filePath).then(r => r.blob()); 
        ''');

    document.body!.append(ScriptElement()
      ..src = 'https://unpkg.com/@api.video/video-uploader'
      ..type = 'application/javascript'
      ..addEventListener('load', (event) {
        jsSetSdkName("flutter-uploader", sdkVersion);
        jsSetChunkSize(50);
      }));
  }

  @override
  Future<void> cancelAll() async {
    return await promiseToFuture(jsCancelAll());
  }

  @override
  void disposeProgressiveUploadSession(String sessionId) {
    jsDisposeProgressiveUploadSession(sessionId);
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
        await promiseToFuture(jsGetBlobFromPath(filePath)),
        token,
        fileName,
        onProgress != null ? js.allowInterop(onProgress) : null,
        videoId));
  }

  // standard upload with api key
  @override
  Future<String> upload(String videoId, String filePath,
      [OnProgress? onProgress]) async {
    return await promiseToFuture(jsUploadWithApiKey(
        await promiseToFuture(jsGetBlobFromPath(filePath)),
        _apiKey,
        onProgress != null ? js.allowInterop(onProgress) : null,
        videoId));
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
    return await promiseToFuture(jsUploadWithUploadTokenPart(
        sessionId,
        await promiseToFuture(jsGetBlobFromPath(filePath)),
        onProgress != null ? js.allowInterop(onProgress) : null));
  }

  @override
  Future<String> uploadWithUploadTokenLastPart(
      String sessionId, String filePath,
      [OnProgress? onProgress]) async {
    return await promiseToFuture(jsUploadWithUploadTokenLastPart(
        sessionId,
        await promiseToFuture(jsGetBlobFromPath(filePath)),
        onProgress != null ? js.allowInterop(onProgress) : null));
  }

  // progressive upload with api key
  @override
  void createProgressiveUploadSession(String sessionId, String videoId) {
    jsCreateProgressiveUploadWithApiKeySession(sessionId, _apiKey, videoId);
  }

  @override
  Future<String> uploadPart(String sessionId, String filePath,
      [OnProgress? onProgress]) async {
    return await promiseToFuture(jsUploadWithUploadTokenPart(
        sessionId,
        await promiseToFuture(jsGetBlobFromPath(filePath)),
        onProgress != null ? js.allowInterop(onProgress) : null));
  }

  @override
  Future<String> uploadLastPart(String sessionId, String filePath,
      [OnProgress? onProgress]) async {
    return await promiseToFuture(jsUploadWithUploadTokenLastPart(
        sessionId,
        await promiseToFuture(jsGetBlobFromPath(filePath)),
        onProgress != null ? js.allowInterop(onProgress) : null));
  }
}
