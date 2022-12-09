@JS('window')
library script.js;

import 'package:js/js.dart';

@JS('uploadWithUploadToken')
external Future<String> jsUploadWithUploadToken(String filePath, String token);
