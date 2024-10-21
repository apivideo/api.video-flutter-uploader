import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';

import 'metadata.dart';
import 'video_assets.dart';
import 'video_source.dart';

part 'video.g.dart';

/// The origin of the last update on the video's `language` attribute.
enum LanguageOrigin {
  /// The language was set by the API.
  @JsonValue("api")
  api,

  /// The language was done automatically by the API.
  @JsonValue("auto")
  auto
}

/// Json converter for [Locale] objects.
class _JsonLocaleConverter extends JsonConverter<Locale, String> {
  const _JsonLocaleConverter();

  @override
  Locale fromJson(String json) {
    return Locale(json);
  }

  @override
  String toJson(Locale object) {
    return object.toLanguageTag();
  }
}

/// A video from api.video
@JsonSerializable()
class Video {
  /// The unique identifier of the video object.
  final String videoId;

  /// When a video was created, presented in ISO-8601 format.
  final DateTime? createdAt;

  /// The title of the video content.
  final String? title;

  /// The description for the video content.
  final String? description;

  /// The date and time the API created the video. Date and time are provided using ISO-8601 UTC format.
  final String? publishedAt;

  /// The date and time the video was updated. Date and time are provided using ISO-8601 UTC format.
  final DateTime? updatedAt;

  /// The date and time the video was discarded.
  final DateTime? discardedAt;

  /// The date and time the video will be permanently deleted.
  final DateTime? deletesAt;

  /// Returns `true` for videos you discarded.
  final bool? discarded;

  /// Returns the language of a video in [IETF language tag](https://en.wikipedia.org/wiki/IETF_language_tag) format.
  @_JsonLocaleConverter()
  final Locale? language;

  /// Returns the origin of the last update on the video's `language` attribute.
  final LanguageOrigin? languageOrigin;

  /// One array of tags (each tag is a string) in order to categorize a video. Tags may include spaces.
  final List<String>? tags;

  /// Metadata you can use to categorise and filter videos. Metadata is a list of dictionaries, where each dictionary represents a key value pair for categorising a video. [Dynamic Metadata](https://api.video/blog/endpoints/dynamic-metadata) allows you to define a key that allows any value pair.
  final List<Metadata>? metadata;

  /// The source information about the video.
  final VideoSource? source;

  /// The details about the video object that you can use to work with the video object.
  final VideoAssets? assets;

  /// The id of the player that will be applied on the video.
  final String? playerId;

  /// Defines if the content is publicly reachable or if a unique token is needed for each play session. Default is true. Tutorials on [private videos](https://api.video/blog/endpoints/private-videos).
  @JsonKey(name: '_public')
  final bool? public;

  /// Defines if video is panoramic.
  final bool? panoramic;

  /// This lets you know whether mp4 is supported. If enabled, an mp4 URL will be provided in the response for the video.
  final bool? mp4Support;

  /// Creates a [Video].
  const Video(this.videoId,
      {this.createdAt,
      this.title,
      this.description,
      this.publishedAt,
      this.updatedAt,
      this.discardedAt,
      this.deletesAt,
      this.discarded,
      this.language,
      this.languageOrigin,
      this.tags,
      this.metadata,
      this.source,
      this.assets,
      this.playerId,
      this.public,
      this.panoramic,
      this.mp4Support});

  /// Creates a [Video] from a [json] map.
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  /// Creates a json map from a [Video].
  Map<String, dynamic> toJson() => _$VideoToJson(this);

  /// Returns a string representation of this object.
  @override
  String toString() {
    return 'Video{${toJson().toString()}';
  }
}
