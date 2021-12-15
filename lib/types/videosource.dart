import 'package:json_annotation/json_annotation.dart';
import 'package:apivideo_uploader/types/videosourcelivestream.dart';

part 'videosource.g.dart';

/// A source information about the video.
@JsonSerializable()
class VideoSource {
  /// The URL where the video is stored.
  final String? uri;
  final String? type;

  /// The live stream information if the video is from a Live stream.
  final VideoSourceLiveStream? liveStream;

  /// Creates a [VideoSource].
  VideoSource({this.uri, this.type, this.liveStream});

  /// Creates a [VideoSource] from a [json] map.
  factory VideoSource.fromJson(Map<String, dynamic> json) =>
      _$VideoSourceFromJson(json);

  /// Creates a json map from a [VideoSource].
  Map<String, dynamic> toJson() => _$VideoSourceToJson(this);
}
