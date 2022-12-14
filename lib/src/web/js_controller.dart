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
  String fileName,
);
