@JS('window')
library script.js;

import 'package:js/js.dart';

@JS('uploadWithUploadToken')
external Future<String> jsUploadWithUploadToken(
  String filePath,
  String token,
  String fileName,
);
@JS('uploadWithApiKey')
external Future<String> jsUploadWithApiKey(
  String filePath,
  String apiKey,
  String videoId,
);
@JS('progressiveUploadWithUploadToken')
external Future<String> jsProgressiveUploadWithToken(
  String filePath,
);
@JS('progressiveUploadWithApiKey')
external Future<String> jsProgressiveUploadWithApiKey(
  String filePath,
);
