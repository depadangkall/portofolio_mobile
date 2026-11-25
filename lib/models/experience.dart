import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

/// Pengalaman portofolio yang disinkronkan dengan API Django REST Framework
/// (`/api/v1/experiences/`, `ExperienceSerializer` dari Tutorial 07).
///
/// Field Dart memakai camelCase dan otomatis dipetakan ke kunci JSON
/// snake_case (mis. `endedAt` <-> `ended_at`) oleh [FieldRename.snake].
@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    required this.title,
    required this.description,
    required this.category,
    this.thumbnail = '',
    this.endedAt,
    this.id,
    this.categoryDisplay = '',
    this.isOngoing = true,
    this.starCount = 0,
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  /// Kategori yang diterima backend (`Experience.EXPERIENCE_CHOICES`).
  static const Map<String, String> categories = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  /// UUID dibuat oleh Django, jadi tidak ikut dikirim saat POST.
  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String description;
  final String category;

  /// URL gambar; backend mengizinkan kosong atau `null`.
  @JsonKey(defaultValue: '')
  final String thumbnail;

  /// `null` berarti pengalaman masih berjalan.
  final DateTime? endedAt;

  // Field di bawah dihitung oleh server (read-only), jadi tidak dikirim.
  @JsonKey(includeToJson: false, defaultValue: '')
  final String categoryDisplay;

  @JsonKey(includeToJson: false, defaultValue: true)
  final bool isOngoing;

  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}
