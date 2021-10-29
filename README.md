[![badge](https://img.shields.io/twitter/follow/api_video?style=social)](https://twitter.com/intent/follow?screen_name=api_video)

[![badge](https://img.shields.io/github/stars/apivideo/flutter-video-uploader?style=social)](https://github.com/apivideo/flutter-video-uploader)

[![badge](https://img.shields.io/discourse/topics?server=https%3A%2F%2Fcommunity.api.video)](https://community.api.video)

![](https://github.com/apivideo/API_OAS_file/blob/master/apivideo_banner.png)

# flutter-video-uploader

This flutter plugin is an easy way to upload video to api.video.

## Installation
Add this to your package's pubspec.yaml file, use the latest version
``` yaml
dependencies:
  apivideouploader: ^latest_version
```


## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

### Example

```Dart
var json = await ApiVideoUploader.uploadVideo("your_Token","imageName" , "imagePath");
```
## Plugins

this project is using external library

| Plugin | README |
| ------ | ------ |
| VideoUploaderIos | [https://github.com/apivideo/VideoUploaderIos][VideoUploaderIos] |
| android-video-uploader | [https://github.com/apivideo/android-video-uploader][android-video-uploader] |


### FAQ
If you have any questions, ask us here:  https://community.api.video .
Or use [Issues].

License
----

MIT License Copyright (c) 2021 api.video


[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

[Issues]: <https://github.com/apivideo/flutter-video-uploader/issues>
[VideoUploaderIos]: <https://github.com/apivideo/VideoUploaderIos>
[android-video-uploader]: <https://github.com/apivideo/android-video-uploader>
