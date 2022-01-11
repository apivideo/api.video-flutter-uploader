// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoSource _$VideoSourceFromJson(Map<String, dynamic> json) => VideoSource(
      uri: json['uri'] as String?,
      type: json['type'] as String?,
      liveStream: json['liveStream'] == null
          ? null
          : VideoSourceLiveStream.fromJson(
              json['liveStream'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VideoSourceToJson(VideoSource instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'type': instance.type,
      'liveStream': instance.liveStream,
    };
