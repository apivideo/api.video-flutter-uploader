// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
      json['videoId'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      title: json['title'] as String?,
      description: json['description'] as String?,
      publishedAt: json['publishedAt'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      metadata: (json['metadata'] as List<dynamic>?)
          ?.map((e) => Metadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      source: json['source'] == null
          ? null
          : VideoSource.fromJson(json['source'] as Map<String, dynamic>),
      assets: json['assets'] == null
          ? null
          : VideoAssets.fromJson(json['assets'] as Map<String, dynamic>),
      playerId: json['playerId'] as String?,
      public: json['_public'] as bool?,
      panoramic: json['panoramic'] as bool?,
      mp4Support: json['mp4Support'] as bool?,
    );

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
      'videoId': instance.videoId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'publishedAt': instance.publishedAt,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'tags': instance.tags,
      'metadata': instance.metadata,
      'source': instance.source,
      'assets': instance.assets,
      'playerId': instance.playerId,
      '_public': instance.public,
      'panoramic': instance.panoramic,
      'mp4Support': instance.mp4Support,
    };
