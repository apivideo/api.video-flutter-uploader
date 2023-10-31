@JS('window')
library script.js;

import 'dart:html';

import 'package:js/js.dart';
import '../../video_uploader.dart';

@JS('UploaderStaticWrapper.setSdkName')
external void jsSetSdkName(String name, String version);

@JS('UploaderStaticWrapper.setApplicationName')
external void jsSetApplicationName(String name, String version);

@JS('UploaderStaticWrapper.setChunkSize')
external void jsSetChunkSize(int size);

@JS('UploaderStaticWrapper.uploadWithUploadToken')
external Future<String> jsUploadWithUploadToken(
  Blob file,
  String token,
  String fileName,
  OnProgress? onProgress,
  String? videoId,
);

@JS('UploaderStaticWrapper.uploadWithApiKey')
external Future<String> jsUploadWithApiKey(
  Blob file,
  String apiKey,
  OnProgress? onProgress,
  String videoId,
);

@JS('UploaderStaticWrapper.createProgressiveUploadWithUploadTokenSession')
external Future<String> jsCreateProgressiveUploadWithUploadTokenSession(
    String sessionId, String token, String? videoId);

@JS('UploaderStaticWrapper.uploadPart')
external Future<String> jsUploadWithUploadTokenPart(
    String sessionId, Blob file, OnProgress? onProgress);

@JS("UploaderStaticWrapper.uploadLastPart")
external Future<String> jsUploadWithUploadTokenLastPart(
    String sessionId, Blob file, OnProgress? onProgress);

@JS("UploaderStaticWrapper.createProgressiveUploadWithApiKeySession")
external void jsCreateProgressiveUploadWithApiKeySession(
    String sessionId, String apiKey, String videoId);

@JS('UploaderStaticWrapper.cancelAll')
external Future<String> jsCancelAll();

@JS('UploaderStaticWrapper.disposeProgressiveUploadSession')
external void jsDisposeProgressiveUploadSession(String sessionId);

@JS('apiVideoGetBlobFromPath')
external Future<Blob> jsGetBlobFromPath(String filePath);
