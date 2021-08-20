import 'package:apivideouploader/apivideouploader.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  var _imageFile;
  var _imageName;
  var _imagePath;
  var imagePicker;
  var type;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 52,
              ),
              Center(
                child: GestureDetector(
                  onTap: () async {

                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        color: Colors.red[200]),
                    child: _imageFile != null
                        ? Image.file(
                      _imageFile,
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.fitHeight,
                    )
                        : Container(
                      decoration: BoxDecoration(
                          color: Colors.red[200]),
                      width: 200,
                      height: 200,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ),
              MaterialButton(
                color: Colors.blue,
                child: Text(
                  "Pick Image from Gallery",
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  var source = ImageSource.gallery;
                  XFile? image = await _picker.pickVideo(
                      source: source);
                  setState(() {
                    try{
                      _imageName = image!.name;
                      _imagePath = image!.path;
                      _imageFile = File(image!.path);
                    }catch(e){

                    }

                  });
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
                  var json = await ApiVideoUploader.uploadVideo("tofLE0dYEe1vqtxBWFotDAM",_imageName , _imagePath, _imagePath);
                  var toto = json;

                },
              ),
            ],
          )
        ),
      ),
    );
  }
}
