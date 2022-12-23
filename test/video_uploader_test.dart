import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_uploader/video_uploader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The mocked method channel
  const MethodChannel channel = const MethodChannel('video.api.uploader');

  test('setEnvironment', () async {
    final environment = Environment.sandbox;
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "setEnvironment");
      expect(methodCall.arguments["environment"], environment.basePath);
      return;
    });
    ApiVideoUploader.setEnvironment(environment);
    channel.setMockMethodCallHandler(null);
  });

  test('setApiKey', () async {
    final apkiKey = "abcde";
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "setApiKey");
      expect(methodCall.arguments["apiKey"], apkiKey);
      return;
    });
    ApiVideoUploader.setApiKey(apkiKey);
    channel.setMockMethodCallHandler(null);
  });

  test('setChunkSize', () async {
    final chunkSize = 10000;
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "setChunkSize");
      expect(methodCall.arguments["size"], chunkSize);
      return chunkSize;
    });
    ApiVideoUploader.setChunkSize(chunkSize);
    channel.setMockMethodCallHandler(null);
  });

  test('upload', () async {
    final videoId = "abcde";
    final filePath = "path/to/file";
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "upload");
      expect(null, isNot(methodCall.arguments["operationId"]));
      expect(methodCall.arguments["videoId"], videoId);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId).toJson());
    });
    expect((await ApiVideoUploader.upload(videoId, filePath)).videoId, videoId);
    channel.setMockMethodCallHandler(null);
  });

  test('uploadWithUploadToken', () async {
    final videoId = "abcde";
    final token = "abcde";
    final filePath = "path/to/file";
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "uploadWithUploadToken");
      expect(null, isNot(methodCall.arguments["operationId"]));
      expect(methodCall.arguments["token"], token);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId).toJson());
    });
    expect(
        (await ApiVideoUploader.uploadWithUploadToken(token, filePath)).videoId,
        videoId);
    channel.setMockMethodCallHandler(null);
  });

  test('uploadWithUploadTokenProgress', () async {
    final videoId = "abcde";
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(null, isNot(methodCall.arguments["operationId"]));
      return jsonEncode(Video(videoId).toJson());
    });
    expect(
        (await ApiVideoUploader.uploadWithUploadToken("abcde", "path/to/file"))
            .videoId,
        videoId);
    channel.setMockMethodCallHandler(null);
  });

  test('progressiveUploadSession', () async {
    final videoId = "abcde";
    final filePath = "path/to/file";

    // Create session
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "createUploadSession");
      expect(methodCall.arguments["videoId"], videoId);
      return;
    });
    final session = ApiVideoUploader.createProgressiveUploadSession(videoId);
    channel.setMockMethodCallHandler(null);

    // Upload part
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "uploadPart");
      expect(null, isNot(methodCall.arguments["operationId"]));
      expect(methodCall.arguments["videoId"], videoId);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId).toJson());
    });
    expect((await session.uploadPart(filePath)).videoId, videoId);
    channel.setMockMethodCallHandler(null);

    // Upload last part
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "uploadLastPart");
      expect(null, isNot(methodCall.arguments["operationId"]));
      expect(methodCall.arguments["videoId"], videoId);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId).toJson());
    });
    expect((await session.uploadLastPart(filePath)).videoId, videoId);
    channel.setMockMethodCallHandler(null);
  });

  test('progressiveUploadWithUploadTokenSession', () async {
    final videoId = "abcde";
    final token = "abcde";
    final filePath = "path/to/file";

    // Create session
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "createUploadWithUploadTokenSession");
      expect(methodCall.arguments["token"], token);
      return;
    });
    final session =
        ApiVideoUploader.createProgressiveUploadWithUploadTokenSession(token);
    channel.setMockMethodCallHandler(null);

    // Upload part
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "uploadPart");
      expect(null, isNot(methodCall.arguments["operationId"]));
      expect(methodCall.arguments["token"], token);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId).toJson());
    });
    expect((await session.uploadPart(filePath)).videoId, videoId);
    channel.setMockMethodCallHandler(null);

    // Upload last part
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "uploadLastPart");
      expect(null, isNot(methodCall.arguments["operationId"]));
      expect(methodCall.arguments["token"], token);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId).toJson());
    });
    expect((await session.uploadLastPart(filePath)).videoId, videoId);
    channel.setMockMethodCallHandler(null);
  });
}
