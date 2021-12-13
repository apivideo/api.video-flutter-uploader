import 'package:json_annotation/json_annotation.dart';

part 'videosourcelivestreamlink.g.dart';

@JsonSerializable()
class VideoSourceLiveStreamLink {
  final String? rel;
  final String? uri;

  VideoSourceLiveStreamLink({this.rel, this.uri});

  factory VideoSourceLiveStreamLink.fromJson(Map<String, dynamic> json) => _$VideoSourceLiveStreamLinkFromJson(json);

  Map<String, dynamic> toJson() => _$VideoSourceLiveStreamLinkToJson(this);
}
