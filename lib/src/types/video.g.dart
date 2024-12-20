// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
      json['videoId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      discardedAt: json['discardedAt'] == null
          ? null
          : DateTime.parse(json['discardedAt'] as String),
      deletesAt: json['deletesAt'] == null
          ? null
          : DateTime.parse(json['deletesAt'] as String),
      discarded: json['discarded'] as bool,
      language: _$JsonConverterFromJson<String, Locale>(
          json['language'], const _JsonLocaleConverter().fromJson),
      languageOrigin:
          $enumDecodeNullable(_$LanguageOriginEnumMap, json['languageOrigin']),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      metadata: (json['metadata'] as List<dynamic>)
          .map((e) => Metadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      source: VideoSource.fromJson(json['source'] as Map<String, dynamic>),
      assets: VideoAssets.fromJson(json['assets'] as Map<String, dynamic>),
      playerId: json['playerId'] as String?,
      public: json['public'] as bool,
      panoramic: json['panoramic'] as bool,
      mp4Support: json['mp4Support'] as bool,
    );

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
      'videoId': instance.videoId,
      'createdAt': instance.createdAt.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'discardedAt': instance.discardedAt?.toIso8601String(),
      'deletesAt': instance.deletesAt?.toIso8601String(),
      'discarded': instance.discarded,
      'language': _$JsonConverterToJson<String, Locale>(
          instance.language, const _JsonLocaleConverter().toJson),
      'languageOrigin': _$LanguageOriginEnumMap[instance.languageOrigin],
      'tags': instance.tags,
      'metadata': instance.metadata,
      'source': instance.source,
      'assets': instance.assets,
      'playerId': instance.playerId,
      'public': instance.public,
      'panoramic': instance.panoramic,
      'mp4Support': instance.mp4Support,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

const _$LanguageOriginEnumMap = {
  LanguageOrigin.api: 'api',
  LanguageOrigin.auto: 'auto',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
