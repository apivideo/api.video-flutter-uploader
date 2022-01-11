import 'package:json_annotation/json_annotation.dart';

part 'video_assets.g.dart';

/// Details about the video object that you can use to work with the video object.
@JsonSerializable()
class VideoAssets {
  /// This is the manifest URL. For HTTP Live Streaming (HLS), when a HLS video stream is initiated, the first file to download is the manifest. This file has the extension M3U8, and provides the video player with information about the various bitrates available for streaming.
  final String? hls;

  /// The code to use video from a third party website
  final String? iframe;

  /// The raw url of the player.
  final String? player;

  /// The poster of the video.
  final String? thumbnail;

  /// Available only if mp4Support is enabled. The raw mp4 url.
  final String? mp4;

  /// Creates a [VideoAssets].
  VideoAssets({this.hls, this.iframe, this.player, this.thumbnail, this.mp4});

  /// Creates a [VideoAssets] from a [json] map.
  factory VideoAssets.fromJson(Map<String, dynamic> json) =>
      _$VideoAssetsFromJson(json);

  /// Creates a json map from a [VideoAssets].
  Map<String, dynamic> toJson() => _$VideoAssetsToJson(this);
}
