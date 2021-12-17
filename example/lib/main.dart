import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_uploader/video_uploader.dart';

const primaryColor = Color(0xFFFA5B30);
const secondaryColor = Color(0xFFFFB39E);

void main() {
  runApp(const UploaderDemo());
}

class UploaderDemo extends StatelessWidget {
  const UploaderDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: primaryColor,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text('Uploader Example'),
        ),
        body: const UploaderPage(),
      ),
    );
  }
}

class UploaderPage extends StatefulWidget {
  const UploaderPage({Key? key}) : super(key: key);

  @override
  UploaderPageState createState() => UploaderPageState();
}

class UploaderPageState extends State<UploaderPage> {
  final _tokenTextController = TextEditingController();
  double _progressValue = 0;
  bool _hasUploadStarted = false;

  void setProgress(double value) async {
    setState(() {
      _progressValue = value;
    });
  }

  @override
  void dispose() {
    _tokenTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 52,
            ),
            TextField(
              cursorColor: primaryColor,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2.0),
                ),
                hintText: 'My video token',
              ),
              controller: _tokenTextController,
            ),
            MaterialButton(
                color: primaryColor,
                child: const Text(
                  "Upload",
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  setState(() {
                    _hasUploadStarted = true;
                  });
                  try {
                    var session =
                        ApiVideoUploader.createProgressiveUploadSession(
                            _tokenTextController.text);

                    var path = await copyAsset("10m.mp4.part.a");
                    var video =
                        await session.uploadPart(path, onProgress: (progress) {
                      log("Part1: Progress : $progress");
                      setProgress(progress.toDouble() / 100);
                    });

                    log("Video : $video");
                    log("Title : ${video.title}");

                    path = await copyAsset("10m.mp4.part.b");
                    video =
                        await session.uploadPart(path, onProgress: (progress) {
                      log("Part2: Progress : $progress");
                      setProgress(progress.toDouble() / 100);
                    });

                    log("Video : $video");
                    log("Title : ${video.title}");

                    path = await copyAsset("10m.mp4.part.c");
                    video = await session.uploadLastPart(path,
                        onProgress: (progress) {
                      log("Part3: Progress : $progress");
                      setProgress(progress.toDouble() / 100);
                    });

                    log("Video : $video");
                    log("Title : ${video.title}");
                    log("VideoId : ${video.videoId}");
                    log("Title : ${video.title}");
                    showSuccessSnackBar(context, "Video ${video.videoId} uploaded");
                  } on Exception catch (e) {
                    log("Failed to upload video: $e");
                    showErrorSnackBar(context, "Failed to upload video: ${(e).message}");
                  } catch (e) {
                    log("Failed to upload video: $e");
                    showErrorSnackBar(context, "Failed to upload video");
                  }
                }),
            _hasUploadStarted
                ? LinearProgressIndicator(
                    color: primaryColor,
                    backgroundColor: secondaryColor,
                    value: _progressValue,
                  )
                : Container(),
            _hasUploadStarted
                ? MaterialButton(
                    color: primaryColor,
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      try {
                        await ApiVideoUploader.cancelAll();
                      } catch (e) {
                        log("Failed to cancel video: $e");
                      }
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 60),
        showCloseIcon: true);
  }

  void showSnackBar(BuildContext context, String message,
      {Color? backgroundColor,
      Duration duration = const Duration(seconds: 4),
      bool showCloseIcon = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        showCloseIcon: showCloseIcon,
      ),
    );
  }
}

extension ErrorExtension on Exception {
  String get message {
    if (this is PlatformException) {
      return (this as PlatformException).message ?? "Unknown error";
    }
    return toString();
  }
}

Future<String> copyAsset(String name) async {
  ByteData data = await rootBundle.load("assets/$name");
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  Directory appDocDir = await getApplicationDocumentsDirectory();
  String path = join(appDocDir.path, name);
  await File(path).writeAsBytes(bytes);

  return path;
}
