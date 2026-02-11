class BurialRequest {
  final int id;
  final String requestNumber;
  final int cemeteryId;
  final String cemeteryName;
  final int burialPrice;
  final int graveId;
  final String sectorNumber;
  final String rowNumber;
  final String graveNumber;
  final int deceasedId;
  final Deceased deceased;
  final String? burialDate;
  final String burialTime;
  final String userPhone;
  final String status;
  final String reservationExpiresAt;
  final bool isComplete;
  final String reservationType;
  final int adjacentGravesCount;
  final String createdAt;
  final String updatedAt;

  BurialRequest({
    required this.id,
    required this.requestNumber,
    required this.cemeteryId,
    required this.cemeteryName,
    required this.burialPrice,
    required this.graveId,
    required this.sectorNumber,
    required this.rowNumber,
    required this.graveNumber,
    required this.deceasedId,
    required this.deceased,
    this.burialDate,
    required this.burialTime,
    required this.userPhone,
    required this.status,
    required this.reservationExpiresAt,
    required this.isComplete,
    required this.reservationType,
    required this.adjacentGravesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BurialRequest.fromJson(Map<String, dynamic> json) {
    return BurialRequest(
      id: (json['id'] as num).toInt(),
      requestNumber: (json['request_number'] as String?) ?? '',
      cemeteryId: (json['cemetery_id'] as num?)?.toInt() ?? 0,
      cemeteryName: (json['cemetery_name'] as String?) ?? '',
      burialPrice: (json['burial_price'] as num?)?.toInt() ?? 0,
      graveId: (json['grave_id'] as num?)?.toInt() ?? 0,
      sectorNumber: (json['sector_number'] as String?) ?? '',
      rowNumber: (json['row_number'] as String?) ?? '',
      graveNumber: (json['grave_number'] as String?) ?? '',
      deceasedId: (json['deceased_id'] as num?)?.toInt() ?? 0,
      deceased: Deceased.fromJson(json['deceased'] as Map<String, dynamic>),
      burialDate: json['burial_date']?.toString(),
      burialTime: (json['burial_time'] as String?) ?? '',
      userPhone: (json['user_phone'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      reservationExpiresAt: (json['reservation_expires_at'] as String?) ?? '',
      isComplete: json['is_complete'] as bool? ?? false,
      reservationType: (json['reservation_type'] as String?) ?? 'single',
      adjacentGravesCount: (json['adjacent_graves_count'] as num?)?.toInt() ?? 0,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_number': requestNumber,
      'cemetery_id': cemeteryId,
      'cemetery_name': cemeteryName,
      'burial_price': burialPrice,
      'grave_id': graveId,
      'sector_number': sectorNumber,
      'row_number': rowNumber,
      'grave_number': graveNumber,
      'deceased_id': deceasedId,
      'deceased': deceased.toJson(),
      'burial_date': burialDate,
      'burial_time': burialTime,
      'user_phone': userPhone,
      'status': status,
      'reservation_expires_at': reservationExpiresAt,
      'is_complete': isComplete,
      'reservation_type': reservationType,
      'adjacent_graves_count': adjacentGravesCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Ожидает подтверждения';
      case 'approved':
        return 'Одобрена';
      case 'rejected':
        return 'Отклонена';
      case 'completed':
        return 'Завершена';
      default:
        return status;
    }
  }
}

class Deceased {
  final int id;
  final int graveId;
  final String fullName;
  final String inn;
  final String? deathDate;
  final String deathCertUrl;
  final bool isReburial;
  final String createdAt;
  final String updatedAt;

  Deceased({
    required this.id,
    required this.graveId,
    required this.fullName,
    required this.inn,
    this.deathDate,
    required this.deathCertUrl,
    required this.isReburial,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Deceased.fromJson(Map<String, dynamic> json) {
    return Deceased(
      id: (json['id'] as num).toInt(),
      graveId: (json['grave_id'] as num?)?.toInt() ?? 0,
      fullName: (json['full_name'] as String?) ?? '',
      inn: (json['inn'] as String?) ?? '',
      deathDate: json['death_date']?.toString(),
      deathCertUrl: (json['death_cert_url'] as String?) ?? '',
      isReburial: json['is_reburial'] as bool? ?? false,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grave_id': graveId,
      'full_name': fullName,
      'inn': inn,
      'death_date': deathDate,
      'death_cert_url': deathCertUrl,
      'is_reburial': isReburial,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class BurialRequestsResponse {
  final List<BurialRequest> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  BurialRequestsResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory BurialRequestsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return BurialRequestsResponse(
        items: [],
        total: 0,
        page: 1,
        limit: 50,
        totalPages: 0,
      );
    }
    final dataMap = data;
    final dataList = dataMap['data'];
    final List<BurialRequest> itemsList = dataList is! List
        ? []
        : dataList
            .map((e) => BurialRequest.fromJson(e as Map<String, dynamic>))
            .toList();
    return BurialRequestsResponse(
      items: itemsList,
      total: (dataMap['total'] as num?)?.toInt() ?? 0,
      page: (dataMap['page'] as num?)?.toInt() ?? 1,
      limit: (dataMap['limit'] as num?)?.toInt() ?? 50,
      totalPages: (dataMap['total_pages'] as num?)?.toInt() ?? 0,
    );
  }
}
