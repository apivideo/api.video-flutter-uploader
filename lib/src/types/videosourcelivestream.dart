import 'package:json_annotation/json_annotation.dart';
import 'videosourcelivestreamlink.dart';

part 'videosourcelivestream.g.dart';

/// A set of live stream information.
@JsonSerializable()
class VideoSourceLiveStream {
  /// The unique identifier for the live stream.
  final String? liveStreamId;
  final List<VideoSourceLiveStreamLink>? links;

  /// Creates a [VideoSourceLiveStream].
  VideoSourceLiveStream({this.liveStreamId, this.links});

  /// Creates a [VideoSourceLiveStream] from a [json] map.
  factory VideoSourceLiveStream.fromJson(Map<String, dynamic> json) =>
      _$VideoSourceLiveStreamFromJson(json);

  /// Creates a json map from a [VideoSourceLiveStream].
  Map<String, dynamic> toJson() => _$VideoSourceLiveStreamToJson(this);
}
