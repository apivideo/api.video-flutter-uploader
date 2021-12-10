import 'dart:developer';

import 'package:apivideo_uploader/apivideo_uploader.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _imagePath;
  final _tokenTextController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _tokenTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Uploader Example'),
        ),
        body: Center(
            child: Column(
          children: [
            SizedBox(
              height: 52,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'My video token'),
                controller: _tokenTextController,
              ),
            ),
            MaterialButton(
              color: Colors.blue,
              child: Text(
                "Pick Video from Gallery",
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                var source = ImageSource.gallery;
                XFile? image = await _picker.pickVideo(source: source);
                if (image != null) {
                  setState(() {
                    try {
                      _imagePath = image.path;
                    } catch (e) {
                      log("Failed to get video: $e");
                    }
                  });
                }
              },
            ),
            MaterialButton(
              color: Colors.blue,
              child: Text(
                "Upload video",
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                try {
                  var json = await ApiVideoUploader.uploadVideo(
                      _tokenTextController.text, _imagePath);
                  log("JSON : $json");
                  log("Title : ${json!["title"]}");
                } catch (e) {
                  log("Failed to upload video: $e");
                }
              },
            ),
          ],
        )),
      ),
    );
  }
}
