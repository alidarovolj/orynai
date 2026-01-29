/// Модель обращения в акимат (ответ API /api/v3/rip-government/v1/appeal/my).
class Appeal {
  final int id;
  final String content;
  final String createTime;
  final AppealType type;
  final AppealAkimatDTO? akimatDTO;
  final AppealStatus status;

  const Appeal({
    required this.id,
    required this.content,
    required this.createTime,
    required this.type,
    this.akimatDTO,
    required this.status,
  });

  factory Appeal.fromJson(Map<String, dynamic> json) {
    return Appeal(
      id: (json['id'] as num).toInt(),
      content: (json['content'] as String?) ?? '',
      createTime: (json['createTime'] as String?) ?? '',
      type: AppealType.fromJson(
        (json['type'] as Map<String, dynamic>?) ?? {},
      ),
      akimatDTO: json['akimatDTO'] != null
          ? AppealAkimatDTO.fromJson(
              json['akimatDTO'] as Map<String, dynamic>,
            )
          : null,
      status: AppealStatus.fromJson(
        (json['status'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

class AppealType {
  final int id;
  final String value;
  final String nameRu;

  const AppealType({
    required this.id,
    required this.value,
    required this.nameRu,
  });

  factory AppealType.fromJson(Map<String, dynamic> json) {
    return AppealType(
      id: (json['id'] as num?)?.toInt() ?? 0,
      value: (json['value'] as String?) ?? '',
      nameRu: (json['nameRu'] as String?) ?? '',
    );
  }
}

class AppealStatus {
  final int id;
  final String value;
  final String name;

  const AppealStatus({
    required this.id,
    required this.value,
    required this.name,
  });

  factory AppealStatus.fromJson(Map<String, dynamic> json) {
    return AppealStatus(
      id: (json['id'] as num?)?.toInt() ?? 0,
      value: (json['value'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
    );
  }
}

class AppealAkimatDTO {
  final int id;
  final String? address;
  final String? mapUrl;
  final String? phone;
  final String? name;
  final int? cityId;

  const AppealAkimatDTO({
    required this.id,
    this.address,
    this.mapUrl,
    this.phone,
    this.name,
    this.cityId,
  });

  factory AppealAkimatDTO.fromJson(Map<String, dynamic> json) {
    return AppealAkimatDTO(
      id: (json['id'] as num).toInt(),
      address: json['address'] as String?,
      mapUrl: json['mapUrl'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      cityId: (json['cityId'] as num?)?.toInt(),
    );
  }
}
