import 'package:json_annotation/json_annotation.dart';

part 'video_source_live_stream_link.g.dart';

@JsonSerializable()
class VideoSourceLiveStreamLink {
  final String? rel;
  final String? uri;

  /// Creates a [VideoSourceLiveStreamLink].
  VideoSourceLiveStreamLink({this.rel, this.uri});

  /// Creates a [VideoSourceLiveStreamLink] from a [json] map.
  factory VideoSourceLiveStreamLink.fromJson(Map<String, dynamic> json) =>
      _$VideoSourceLiveStreamLinkFromJson(json);

  /// Creates a json map from a [VideoSourceLiveStreamLink].
  Map<String, dynamic> toJson() => _$VideoSourceLiveStreamLinkToJson(this);
}
