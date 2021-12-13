import 'package:json_annotation/json_annotation.dart';
import 'package:apivideo_uploader/types/videoassets.dart';
import 'package:apivideo_uploader/types/videosource.dart';
import 'package:apivideo_uploader/types/metadata.dart';

part 'video.g.dart';

@JsonSerializable()
class Video {
  final String videoId;
  final DateTime? createdAt;
  final String? title;
  final String? description;
  final String? publishedAt;
  final DateTime? updatedAt;
  final List<String>? tags;
  final List<Metadata>? metadata;
  final VideoSource? source;
  final VideoAssets? assets;
  final String? playerId;
  @JsonKey(name: '_public')
  final bool? public;

  final bool? panoramic;
  final bool? mp4Support;

  Video(
      {required this.videoId,
      this.createdAt,
      this.title,
      this.description,
      this.publishedAt,
      this.updatedAt,
      this.tags,
      this.metadata,
      this.source,
      this.assets,
      this.playerId,
      this.public,
      this.panoramic,
      this.mp4Support});

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  Map<String, dynamic> toJson() => _$VideoToJson(this);
}
