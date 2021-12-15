// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'videoassets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoAssets _$VideoAssetsFromJson(Map<String, dynamic> json) => VideoAssets(
      hls: json['hls'] as String?,
      iframe: json['iframe'] as String?,
      player: json['player'] as String?,
      thumbnail: json['thumbnail'] as String?,
      mp4: json['mp4'] as String?,
    );

Map<String, dynamic> _$VideoAssetsToJson(VideoAssets instance) =>
    <String, dynamic>{
      'hls': instance.hls,
      'iframe': instance.iframe,
      'player': instance.player,
      'thumbnail': instance.thumbnail,
      'mp4': instance.mp4,
    };
