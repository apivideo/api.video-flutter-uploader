import 'package:json_annotation/json_annotation.dart';
import 'package:apivideo_uploader/types/videosourcelivestream.dart';

part 'videosource.g.dart';

@JsonSerializable()
class VideoSource {
  final String? uri;
  final String? type;
  final VideoSourceLiveStream? liveStream;

  VideoSource({this.uri, this.type, this.liveStream});

  factory VideoSource.fromJson(Map<String, dynamic> json) =>
      _$VideoSourceFromJson(json);

  Map<String, dynamic> toJson() => _$VideoSourceToJson(this);
}
