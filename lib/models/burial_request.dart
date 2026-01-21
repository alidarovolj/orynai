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
      id: json['id'] as int,
      requestNumber: json['request_number'] as String,
      cemeteryId: json['cemetery_id'] as int,
      cemeteryName: json['cemetery_name'] as String,
      burialPrice: json['burial_price'] as int,
      graveId: json['grave_id'] as int,
      sectorNumber: json['sector_number'] as String,
      rowNumber: json['row_number'] as String,
      graveNumber: json['grave_number'] as String,
      deceasedId: json['deceased_id'] as int,
      deceased: Deceased.fromJson(json['deceased'] as Map<String, dynamic>),
      burialDate: json['burial_date']?.toString(),
      burialTime: json['burial_time'] as String? ?? '',
      userPhone: json['user_phone'] as String,
      status: json['status'] as String,
      reservationExpiresAt: json['reservation_expires_at'] as String,
      isComplete: json['is_complete'] as bool,
      reservationType: json['reservation_type'] as String,
      adjacentGravesCount: json['adjacent_graves_count'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
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
      id: json['id'] as int,
      graveId: json['grave_id'] as int,
      fullName: json['full_name'] as String,
      inn: json['inn'] as String,
      deathDate: json['death_date']?.toString(),
      deathCertUrl: json['death_cert_url'] as String? ?? '',
      isReburial: json['is_reburial'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
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
    final data = json['data'] as Map<String, dynamic>;
    return BurialRequestsResponse(
      items: (data['data'] as List)
          .map((item) => BurialRequest.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int,
      page: data['page'] as int,
      limit: data['limit'] as int,
      totalPages: data['total_pages'] as int,
    );
  }
}
