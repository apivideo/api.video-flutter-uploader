import 'package:json_annotation/json_annotation.dart';
import 'package:apivideo_uploader/types/videosourcelivestreamlink.dart';

part 'videosourcelivestream.g.dart';

@JsonSerializable()
class VideoSourceLiveStream {
  final String? liveStreamId;
  final List<VideoSourceLiveStreamLink>? links;

  VideoSourceLiveStream({this.liveStreamId, this.links});

  factory VideoSourceLiveStream.fromJson(Map<String, dynamic> json) =>
      _$VideoSourceLiveStreamFromJson(json);

  Map<String, dynamic> toJson() => _$VideoSourceLiveStreamToJson(this);
}
