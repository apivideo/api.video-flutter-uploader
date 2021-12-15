import 'dart:convert';
import 'package:apivideo_uploader/types/environment.dart';
import 'package:apivideo_uploader/types/video.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apivideo_uploader/apivideo_uploader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = const MethodChannel('video.api/uploader');

  test('setApiKey', () async {
    final environment = Environment.sandbox;
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "setEnvironment");
      expect(methodCall.arguments["environment"], environment.name);
      return;
    });
    ApiVideoUploader.setEnvironment(environment);
    channel.setMockMethodCallHandler(null);
  });

  test('setEnvironment', () async {
    final apkiKey = "abcde";
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "setApiKey");
      expect(methodCall.arguments["apiKey"], apkiKey);
      return;
    });
    ApiVideoUploader.setApiKey(apkiKey);
    channel.setMockMethodCallHandler(null);
  });

  test('upload', () async {
    final videoId = "abcde";
    final filePath = "path/to/file";
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "upload");
      expect(methodCall.arguments["videoId"], videoId);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId: videoId).toJson());
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
      expect(methodCall.arguments["token"], token);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId: videoId).toJson());
    });
    expect((await ApiVideoUploader.uploadWithUploadToken(token, filePath)).videoId, videoId);
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
      expect(methodCall.arguments["videoId"], videoId);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId: videoId).toJson());
    });
    expect((await session.uploadPart(filePath)).videoId, videoId);
    channel.setMockMethodCallHandler(null);

    // Upload last part
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "uploadLastPart");
      expect(methodCall.arguments["videoId"], videoId);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId: videoId).toJson());
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
    final session = ApiVideoUploader.createProgressiveUploadWithUploadTokenSession(token);
    channel.setMockMethodCallHandler(null);

    // Upload part
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "uploadPart");
      expect(methodCall.arguments["token"], token);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId: videoId).toJson());
    });
    expect((await session.uploadPart(filePath)).videoId, videoId);
    channel.setMockMethodCallHandler(null);

    // Upload last part
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "uploadLastPart");
      expect(methodCall.arguments["token"], token);
      expect(methodCall.arguments["filePath"], filePath);
      return jsonEncode(Video(videoId: videoId).toJson());
    });
    expect((await session.uploadLastPart(filePath)).videoId, videoId);
    channel.setMockMethodCallHandler(null);
  });
}
