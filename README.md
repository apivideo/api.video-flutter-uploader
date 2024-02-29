<!--<documentation_excluded>-->
[![badge](https://img.shields.io/twitter/follow/api_video?style=social)](https://twitter.com/intent/follow?screen_name=api_video)
&nbsp; [![badge](https://img.shields.io/github/stars/apivideo/api.video-flutter-uploader?style=social)](https://github.com/apivideo/api.video-flutter-uploader)
&nbsp; [![badge](https://img.shields.io/discourse/topics?server=https%3A%2F%2Fcommunity.api.video)](https://community.api.video)
![](https://github.com/apivideo/.github/blob/main/assets/apivideo_banner.png)
<h1 align="center">api.video Flutter video uploader</h1>

[api.video](https://api.video) is the video infrastructure for product builders. Lightning fast
video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in
your app.

## Table of contents

- [Table of contents](#table-of-contents)
- [Project description](#project-description)
- [Getting started](#getting-started)
    - [Installation](#installation)
    - [Android](#android)
        - [Permissions](#permissions)
        - [Notifications](#notifications)
    - [Code sample](#code-sample)
- [Dependencies](#dependencies)
- [FAQ](#faq)

<!--</documentation_excluded>-->
<!--<documentation_only>
---
title: api.video Flutter video uploader
meta: 
  description: The official api.video Flutter video uploader for api.video. [api.video](https://api.video/) is the video infrastructure for product builders. Lightning fast video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in your app.
---

# api.video Flutter video uploader

[api.video](https://api.video/) is the video infrastructure for product builders. Lightning fast video APIs for integrating, scaling, and managing on-demand & low latency live streaming features in your app.

</documentation_only>-->
## Project description

api.video's Flutter uploader uploads videos to api.video using delegated upload token or API Key.

It allows you to upload videos in two ways:

- standard upload: to send a whole video file in one go
- progressive upload: to send a video file by chunks, without needing to know the final size of the
  video file

## Getting started

### Installation

Run the following command at the root of your project:

```bash
flutter pub add video_uploader
 ```

This will add the following lines to your package's pubspec.yaml file:

``` yaml
dependencies:
  video_uploader: ^1.2.2
```

### Android

#### Permissions

Permissions `android.permission.READ_MEDIA_VIDEO` (for API 33+)
or `android.permission.READ_EXTERNAL_STORAGE` (for API < 33) will be requested by this library at
runtime.

The uploader comes with a notification to show the progress. So if your application targets Android
33+, you might request `android.permission.POST_NOTIFICATIONS` permission at runtime.

When targeting Android API Level 34+, you must declare the service type in your application's manifest file.
In your `AndroidManifest.xml` file, add the following lines in the `<application>` tag:

```xml

<service 
    android:name="androidx.work.impl.foreground.SystemForegroundService"
    android:exported="false" 
    android:foregroundServiceType="dataSync" />
```

#### Notifications

To customize the notification to your own brand, you can change the icon, color or channel name by
overwriting the following resources in your own application resources:

- the icon: `R.drawable.ic_upload_notification`
- the color: `R.color.upload_notification_color`
- the channel name: `R.string.upload_notification_channel_name`

### Code sample

```dart
import 'package:video_uploader/video_uploader.dart';

var video = await ApiVideoUploader.uploadWithUploadToken("YOUR_UPLOAD_TOKEN", "path/to/my-video.mp4");
```

## Dependencies

This project is using external library

| Plugin                 | README                                                                           |
|------------------------|----------------------------------------------------------------------------------|
| Swift-video-uploader   | [Swift-video-uploader](https://github.com/apivideo/api.video-swift-uploader)     |
| android-video-uploader | [android-video-uploader](https://github.com/apivideo/api.video-android-uploader) |

## FAQ

If you have any questions, ask us in the [community](https://community.api.video) or
use [Issues](https://github.com/apivideo/api.video-flutter-uploader/issues).
