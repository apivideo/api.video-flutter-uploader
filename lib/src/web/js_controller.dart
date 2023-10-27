@JS('window')
library script.js;

import 'package:js/js.dart';
import '../../video_uploader.dart';

@JS('setApplicationName')
external void jsSetApplicationName(String name, String version);

@JS('setChunkSize')
external void jsSetChunkSize(int size);

@JS('uploadWithUploadToken')
external Future<String> jsUploadWithUploadToken(
  String filePath,
  String token,
  String fileName,
  OnProgress? onProgress,
  String? videoId,
);

@JS('uploadWithApiKey')
external Future<String> jsUploadWithApiKey(
  String filePath,
  String apiKey,
  OnProgress? onProgress,
  String videoId,
);

@JS('createProgressiveUploadWithUploadTokenSession')
external Future<String> jsCreateProgressiveUploadWithUploadTokenSession(
    String sessionId, String token, String? videoId);

@JS('uploadPart')
external Future<String> jsUploadWithUploadTokenPart(
    String sessionId, String filePath, OnProgress? onProgress);

@JS("uploadLastPart")
external Future<String> jsUploadWithUploadTokenLastPart(
    String sessionId, String filePath, OnProgress? onProgress);

@JS("createProgressiveUploadWithApiKeySession")
external void jsCreateProgressiveUploadWithApiKeySession(
    String sessionId, String apiKey, String videoId);

@JS('cancelAll')
external Future<String> jsCancelAll();

@JS('disposeProgressiveUploadSession')
external void jsDisposeProgressiveUploadSession(String sessionId);
