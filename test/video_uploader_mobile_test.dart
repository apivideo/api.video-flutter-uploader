import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_uploader/src/video_uploader_platform_interface.dart';
import 'package:video_uploader/video_uploader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The mocked method channel
  const MethodChannel channel = const MethodChannel('video.api.uploader');
  ApiVideoUploaderPlatform.instance = ApiVideoMobileUploaderPlugin();

  test('setEnvironment', () async {
    final environment = Environment.sandbox;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      expect(methodCall.method, "setEnvironment");
      expect(methodCall.arguments["environment"], environment.basePath);
      return;
    });
    ApiVideoUploader.setEnvironment(environment);
  });

  test('setApiKey', () async {
    final apkiKey = "abcde";
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      expect(methodCall.method, "setApiKey");
      expect(methodCall.arguments["apiKey"], apkiKey);
      return;
    });
    ApiVideoUploader.setApiKey(apkiKey);
  });

  test('setChunkSize', () async {
    final chunkSize = 10000;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      expect(methodCall.method, "setChunkSize");
      expect(methodCall.arguments["size"], chunkSize);
      return chunkSize;
    });
    ApiVideoUploader.setChunkSize(chunkSize);
  });

  test('upload', () async {
    final videoId = "abcde";
    final filePath = "path/to/file";
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == "setSdkNameVersion") {
        return null;
      } else if (methodCall.method == "upload") {
        expect(methodCall.method, "upload");
        expect(null, isNot(methodCall.arguments["uploadId"]));
        expect(methodCall.arguments["videoId"], videoId);
        expect(methodCall.arguments["filePath"], filePath);
        return jsonEncode(Video(videoId).toJson());
      } else {
        fail("Method not expected: ${methodCall.method}");
      }
    });
    expect((await ApiVideoUploader.upload(videoId, filePath)).videoId, videoId);
  });

  test('uploadWithUploadToken', () async {
    final videoId = "abcde";
    final token = "abcde";
    final filePath = "path/to/file";
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == "setSdkNameVersion") {
        return null;
      } else if (methodCall.method == "uploadWithUploadToken") {
        expect(methodCall.method, "uploadWithUploadToken");
        expect(null, isNot(methodCall.arguments["uploadId"]));
        expect(methodCall.arguments["token"], token);
        expect(methodCall.arguments["filePath"], filePath);
        return jsonEncode(Video(videoId).toJson());
      } else {
        fail("Method not expected: ${methodCall.method}");
      }
    });
    expect(
        (await ApiVideoUploader.uploadWithUploadToken(token, filePath)).videoId,
        videoId);
  });

  test('uploadWithUploadTokenProgress', () async {
    final videoId = "abcde";
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == "setSdkNameVersion") {
        return null;
      } else if (methodCall.method == "uploadWithUploadToken") {
        expect(null, isNot(methodCall.arguments["uploadId"]));
        return jsonEncode(Video(videoId).toJson());
      } else {
        fail("Method not expected: ${methodCall.method}");
      }
    });
    expect(
        (await ApiVideoUploader.uploadWithUploadToken("abcde", "path/to/file"))
            .videoId,
        videoId);
  });

  test('progressiveUploadSession', () async {
    final videoId = "abcde";
    final filePath = "path/to/file";
    late final String sessionId;

    // Create session
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      expect(methodCall.method, "createProgressiveUploadSession");
      sessionId = methodCall.arguments["sessionId"];
      return;
    });
    final session = ApiVideoUploader.createProgressiveUploadSession(videoId);

    // Upload part
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == "setSdkNameVersion") {
        return null;
      } else if (methodCall.method == "uploadPart") {
        expect(methodCall.method, "uploadPart");
        expect(null, isNot(methodCall.arguments["uploadId"]));
        expect(methodCall.arguments["sessionId"], sessionId);
        expect(methodCall.arguments["filePath"], filePath);
        return jsonEncode(Video(videoId).toJson());
      } else {
        fail("Method not expected: ${methodCall.method}");
      }
    });
    expect((await session.uploadPart(filePath)).videoId, videoId);

    // Upload last part
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == "setSdkNameVersion") {
        return null;
      } else if (methodCall.method == "uploadLastPart") {
        expect(methodCall.method, "uploadLastPart");
        expect(null, isNot(methodCall.arguments["uploadId"]));
        expect(methodCall.arguments["sessionId"], sessionId);
        expect(methodCall.arguments["filePath"], filePath);
        return jsonEncode(Video(videoId).toJson());
      } else {
        fail("Method not expected: ${methodCall.method}");
      }
    });
    expect((await session.uploadLastPart(filePath)).videoId, videoId);
  });

  test('progressiveUploadWithUploadTokenSession', () async {
    final videoId = "abcde";
    final token = "abcde";
    final filePath = "path/to/file";
    late final String sessionId;

    // Create session
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      expect(
          methodCall.method, "createProgressiveUploadWithUploadTokenSession");
      expect(methodCall.arguments["token"], token);
      sessionId = methodCall.arguments["sessionId"];
      return;
    });
    final session =
        ApiVideoUploader.createProgressiveUploadWithUploadTokenSession(token);

    // Upload part
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == "setSdkNameVersion") {
        return null;
      } else if (methodCall.method == "uploadPart") {
        expect(methodCall.method, "uploadPart");
        expect(null, isNot(methodCall.arguments["uploadId"]));
        expect(methodCall.arguments["sessionId"], sessionId);
        expect(methodCall.arguments["filePath"], filePath);
        return jsonEncode(Video(videoId).toJson());
      } else {
        fail("Method not expected: ${methodCall.method}");
      }
    });
    expect((await session.uploadPart(filePath)).videoId, videoId);

    // Upload last part
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == "setSdkNameVersion") {
        return null;
      } else if (methodCall.method == "uploadLastPart") {
        expect(methodCall.method, "uploadLastPart");
        expect(null, isNot(methodCall.arguments["uploadId"]));
        expect(methodCall.arguments["sessionId"], sessionId);
        expect(methodCall.arguments["filePath"], filePath);
        return jsonEncode(Video(videoId).toJson());
      } else {
        fail("Method not expected: ${methodCall.method}");
      }
    });
    expect((await session.uploadLastPart(filePath)).videoId, videoId);
  });
}
