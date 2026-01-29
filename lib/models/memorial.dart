/// Модель цифрового мемориала (ответ API /api/v1/memorials).
class Memorial {
  final int id;
  final int deceasedId;
  final String creatorPhone;
  final List<String> photoUrls;
  final String? epitaph;
  final String? aboutPerson;
  final List<String> achievementUrls;
  final List<String> videoUrls;
  final bool isPublic;
  final bool canEdit;
  final String createdAt;
  final String updatedAt;

  const Memorial({
    required this.id,
    required this.deceasedId,
    required this.creatorPhone,
    required this.photoUrls,
    this.epitaph,
    this.aboutPerson,
    required this.achievementUrls,
    required this.videoUrls,
    required this.isPublic,
    this.canEdit = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Memorial.fromJson(Map<String, dynamic> json) {
    return Memorial(
      id: (json['id'] as num).toInt(),
      deceasedId: (json['deceased_id'] as num).toInt(),
      creatorPhone: (json['creator_phone'] as String?) ?? '',
      photoUrls: _toStringList(json['photo_urls']),
      epitaph: json['epitaph'] as String?,
      aboutPerson: json['about_person'] as String?,
      achievementUrls: _toStringList(json['achievement_urls']),
      videoUrls: _toStringList(json['video_urls']),
      isPublic: json['is_public'] as bool? ?? false,
      canEdit: json['can_edit'] as bool? ?? false,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    final list = value is List ? value : null;
    if (list == null) return [];
    return list.map((e) => e.toString()).toList();
  }
}
