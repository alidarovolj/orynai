/// Заявка на перезахоронение (ответ API /api/v3/rip-government/v1/request/my).
class ReburialRequestItem {
  final int id;
  final String userPhone;
  final int fromBurialId;
  final int toBurialId;
  final String reason;
  final ReburialRequestStatus status;
  final ReburialRequestUser? user;
  final ReburialRequestAkimatDTO? akimatDTO;
  final ReburialRequestFileRef? deathCertificate;
  final ReburialRequestFileRef? proofOfRelation;
  final ReburialRequestFileRef? graveDoc;
  final String? foreignCemetery;

  const ReburialRequestItem({
    required this.id,
    required this.userPhone,
    required this.fromBurialId,
    required this.toBurialId,
    required this.reason,
    required this.status,
    this.user,
    this.akimatDTO,
    this.deathCertificate,
    this.proofOfRelation,
    this.graveDoc,
    this.foreignCemetery,
  });

  factory ReburialRequestItem.fromJson(Map<String, dynamic> json) {
    return ReburialRequestItem(
      id: (json['id'] as num).toInt(),
      userPhone: (json['userPhone'] as String?) ?? '',
      fromBurialId: (json['fromBurialId'] as num?)?.toInt() ?? 0,
      toBurialId: (json['toBurialId'] as num?)?.toInt() ?? 0,
      reason: (json['reason'] as String?) ?? '',
      status: ReburialRequestStatus.fromJson(
        (json['status'] as Map<String, dynamic>?) ?? {},
      ),
      user: json['user'] != null
          ? ReburialRequestUser.fromJson(
              json['user'] as Map<String, dynamic>,
            )
          : null,
      akimatDTO: json['akimatDTO'] != null
          ? ReburialRequestAkimatDTO.fromJson(
              json['akimatDTO'] as Map<String, dynamic>,
            )
          : null,
      deathCertificate: json['death_certificate'] != null
          ? ReburialRequestFileRef.fromJson(
              json['death_certificate'] as Map<String, dynamic>,
            )
          : null,
      proofOfRelation: json['proof_of_relation'] != null
          ? ReburialRequestFileRef.fromJson(
              json['proof_of_relation'] as Map<String, dynamic>,
            )
          : null,
      graveDoc: json['grave_doc'] != null
          ? ReburialRequestFileRef.fromJson(
              json['grave_doc'] as Map<String, dynamic>,
            )
          : null,
      foreignCemetery: json['foreign_cemetery'] as String?,
    );
  }
}

class ReburialRequestStatus {
  final int id;
  final String value;
  final String nameRu;

  const ReburialRequestStatus({
    required this.id,
    required this.value,
    required this.nameRu,
  });

  factory ReburialRequestStatus.fromJson(Map<String, dynamic> json) {
    return ReburialRequestStatus(
      id: (json['id'] as num?)?.toInt() ?? 0,
      value: (json['value'] as String?) ?? '',
      nameRu: (json['nameRu'] as String?) ?? '',
    );
  }
}

class ReburialRequestUser {
  final int id;
  final String name;
  final String surname;
  final String? patronymic;
  final String? iin;
  final String phone;
  final String fio;

  const ReburialRequestUser({
    required this.id,
    required this.name,
    required this.surname,
    this.patronymic,
    this.iin,
    required this.phone,
    required this.fio,
  });

  factory ReburialRequestUser.fromJson(Map<String, dynamic> json) {
    return ReburialRequestUser(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      surname: (json['surname'] as String?) ?? '',
      patronymic: json['patronymic'] as String?,
      iin: json['iin'] as String?,
      phone: (json['phone'] as String?) ?? '',
      fio: (json['fio'] as String?) ?? '',
    );
  }
}

class ReburialRequestAkimatDTO {
  final int id;
  final String? address;
  final String? mapUrl;
  final String? phone;
  final String? name;
  final int? cityId;

  const ReburialRequestAkimatDTO({
    required this.id,
    this.address,
    this.mapUrl,
    this.phone,
    this.name,
    this.cityId,
  });

  factory ReburialRequestAkimatDTO.fromJson(Map<String, dynamic> json) {
    return ReburialRequestAkimatDTO(
      id: (json['id'] as num).toInt(),
      address: json['address'] as String?,
      mapUrl: json['mapUrl'] as String?,
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      cityId: (json['cityId'] as num?)?.toInt(),
    );
  }
}

class ReburialRequestFileRef {
  final int id;
  final String url;

  const ReburialRequestFileRef({
    required this.id,
    required this.url,
  });

  factory ReburialRequestFileRef.fromJson(Map<String, dynamic> json) {
    return ReburialRequestFileRef(
      id: (json['id'] as num).toInt(),
      url: (json['url'] as String?) ?? '',
    );
  }
}
