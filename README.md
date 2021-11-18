[![badge](https://img.shields.io/twitter/follow/api_video?style=social)](https://twitter.com/intent/follow?screen_name=api_video) &nbsp; [![badge](https://img.shields.io/github/stars/apivideo/api.video-flutter-uploader?style=social)](https://github.com/apivideo/api.video-flutter-uploader) &nbsp; [![badge](https://img.shields.io/discourse/topics?server=https%3A%2F%2Fcommunity.api.video)](https://community.api.video)
![](https://github.com/apivideo/API_OAS_file/blob/master/apivideo_banner.png)
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

# Project description

This flutter plugin is an easy way to upload video to api.video.

# Getting started

## Installation
Add this to your package's pubspec.yaml file, use the latest version
``` yaml
dependencies:
  apivideouploader: ^latest_version
```

### Code sample

```Dart
var json = await ApiVideoUploader.uploadVideo("your_Token","imageName" , "imagePath");
```
## Plugins

this project is using external library

| Plugin | README |
| ------ | ------ |
| VideoUploaderIos | [https://github.com/apivideo/VideoUploaderIos][VideoUploaderIos] |
| android-video-uploader | [https://github.com/apivideo/android-video-uploader][android-video-uploader] |


# FAQ
If you have any questions, ask us here:  https://community.api.video .
Or use [Issues].


[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

[Issues]: <https://github.com/apivideo/api.video-flutter-uploader/issues>
[VideoUploaderIos]: <https://github.com/apivideo/VideoUploaderIos>
[android-video-uploader]: <https://github.com/apivideo/android-video-uploader>
