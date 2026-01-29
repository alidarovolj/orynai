/// Модель умершего (ответ API /api/v9/deceased/{id}).
class Deceased {
  final int id;
  final int graveId;
  final String fullName;
  final String? inn;
  final String? deathCertUrl;
  final bool isReburial;
  final String createdAt;
  final String updatedAt;

  const Deceased({
    required this.id,
    required this.graveId,
    required this.fullName,
    this.inn,
    this.deathCertUrl,
    required this.isReburial,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Deceased.fromJson(Map<String, dynamic> json) {
    return Deceased(
      id: (json['id'] as num).toInt(),
      graveId: (json['grave_id'] as num).toInt(),
      fullName: (json['full_name'] as String?) ?? '',
      inn: json['inn'] as String?,
      deathCertUrl: json['death_cert_url'] as String?,
      isReburial: json['is_reburial'] as bool? ?? false,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
    );
  }
}
