import 'package:json_annotation/json_annotation.dart';

part 'videoassets.g.dart';

@JsonSerializable()
class VideoAssets {
  final String? hls;
  final String? iframe;
  final String? player;
  final String? thumbnail;
  final String? mp4;

  VideoAssets({this.hls, this.iframe, this.player, this.thumbnail, this.mp4});

  factory VideoAssets.fromJson(Map<String, dynamic> json) => _$VideoAssetsFromJson(json);

  Map<String, dynamic> toJson() => _$VideoAssetsToJson(this);
}
