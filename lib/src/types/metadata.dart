import 'package:json_annotation/json_annotation.dart';

part 'metadata.g.dart';

/// A list of key value pairs that you use to provide metadata for your video.
/// These pairs can be made dynamic, allowing you to segment your audience. You
/// can also just use the pairs as another way to tag and categorize your
/// videos.
@JsonSerializable()
class Metadata {
  /// The constant that defines the data set.
  final String? key;

  /// The variable which belongs to the data set.
  final String? value;

  /// Creates a [Metadata].
  Metadata({this.key, this.value});

  /// Creates a [Metadata] from a [json] map.
  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);

  /// Creates a json map from a [Metadata].
  Map<String, dynamic> toJson() => _$MetadataToJson(this);
}
