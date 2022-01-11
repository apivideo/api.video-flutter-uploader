// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_source_live_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoSourceLiveStream _$VideoSourceLiveStreamFromJson(
        Map<String, dynamic> json) =>
    VideoSourceLiveStream(
      liveStreamId: json['liveStreamId'] as String?,
      links: (json['links'] as List<dynamic>?)
          ?.map((e) =>
              VideoSourceLiveStreamLink.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VideoSourceLiveStreamToJson(
        VideoSourceLiveStream instance) =>
    <String, dynamic>{
      'liveStreamId': instance.liveStreamId,
      'links': instance.links,
    };
