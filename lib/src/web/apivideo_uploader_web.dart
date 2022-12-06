import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

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
        // final String url = call.arguments['url'];
        return 'FROM WEB';
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The url_launcher plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }
}
