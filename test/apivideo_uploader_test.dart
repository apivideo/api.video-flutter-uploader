import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apivideo_uploader/apivideo_uploader.dart';

void main() {
  const MethodChannel channel = MethodChannel('video.api/uploader');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  /*test('getPlatformVersion', () async {
    expect(await ApiVideoUploader.platformVersion, '42');
  });*/
}
