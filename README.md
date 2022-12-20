[![badge](https://img.shields.io/twitter/follow/api_video?style=social)](https://twitter.com/intent/follow?screen_name=api_video) &nbsp; [![badge](https://img.shields.io/github/stars/apivideo/api.video-flutter-uploader?style=social)](https://github.com/apivideo/api.video-flutter-uploader) &nbsp; [![badge](https://img.shields.io/discourse/topics?server=https%3A%2F%2Fcommunity.api.video)](https://community.api.video)
![](https://github.com/apivideo/.github/blob/main/assets/apivideo_banner.png)
<h1 align="center">api.video Flutter video uploader</h1>

[api.video](https://api.video) is the video infrastructure for product builders. Lightning fast video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in your app.

# Table of contents

- [Table of contents](#table-of-contents)
- [Project description](#project-description)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Code sample](#code-sample)
- [Plugins](#plugins)
- [FAQ](#faq)
- [Found this video uploader useful?](#found-this-video-uploader-useful)

# Project description

api.video's Flutter uploader uploads videos to api.video using delegated upload token or API Key.

It allows you to upload videos in two ways:

- standard upload: to send a whole video file in one go
- progressive upload: to send a video file by chunks, without needing to know the final size of the video file

# Getting started

### Installation

Run this command:

```bash
flutter pub add video_uploader
 ```
 
This will add the following lines to your package's pubspec.yaml file:

``` yaml
dependencies:
  video_uploader: ^1.0.0
```

### Code sample

```dart
import 'package:video_uploader/video_uploader.dart';

var video = await ApiVideoUploader.uploadWithUploadToken("MY_VIDEO_TOKEN", "path/to/my-video.mp4");
```

# Dependencies

This project is using external library

| Plugin | README |
| ------ | ------ |
| iOS-video-uploader | [iOS-video-uploader](https://github.com/apivideo/api.video-ios-uploader) |
| android-video-uploader | [android-video-uploader](https://github.com/apivideo/api.video-android-uploader) |

# FAQ

If you have any questions, ask us here: [https://community.api.video](https://community.api.video).
Or use [Issues](https://github.com/apivideo/api.video-flutter-uploader/issues).

# Found this video uploader useful?

Please star ⭐ the repo to help others find it.
