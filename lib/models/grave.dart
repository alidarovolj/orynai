class Grave {
  final int id;
  final int cemeteryId;
  final String cemeteryName;
  final String sectorNumber;
  final String rowNumber;
  final String graveNumber;
  final String status;
  final int width;
  final int height;
  final PolygonData polygonData;

  Grave({
    required this.id,
    required this.cemeteryId,
    required this.cemeteryName,
    required this.sectorNumber,
    required this.rowNumber,
    required this.graveNumber,
    required this.status,
    required this.width,
    required this.height,
    required this.polygonData,
  });

  factory Grave.fromJson(Map<String, dynamic> json) {
    return Grave(
      id: json['id'],
      cemeteryId: json['cemetery_id'],
      cemeteryName: json['cemetery_name'],
      sectorNumber: json['sector_number'],
      rowNumber: json['row_number'],
      graveNumber: json['grave_number'],
      status: json['status'],
      width: json['width'],
      height: json['height'],
      polygonData: PolygonData.fromJson(json['polygon_data']),
    );
  }

  bool get isFree => status == 'free';
  bool get isReserved => status == 'reserved';
  bool get isOccupied => status == 'occupied';
}

class PolygonData {
  final List<List<double>> coordinates;
  final String color;
  final int strokeWidth;
  final String strokeColor;

  PolygonData({
    required this.coordinates,
    required this.color,
    required this.strokeWidth,
    required this.strokeColor,
  });

  factory PolygonData.fromJson(Map<String, dynamic> json) {
    return PolygonData(
      coordinates: (json['coordinates'] as List)
          .map((coord) => List<double>.from(coord))
          .toList(),
      color: json['color'] ?? '#008000',
      strokeWidth: json['stroke_width'] ?? 2,
      strokeColor: json['stroke_color'] ?? '#000000',
    );
  }
}
