class Cemetery {
  final int id;
  final String name;
  final String description;
  final String country;
  final String city;
  final String streetName;
  final String? nameKz;
  final String? descriptionKz;
  final String phone;
  final List<double> locationCoords;
  final List<List<double>> polygonCoordinates;
  final String religion;
  final int burialPrice;
  final String status;
  final int capacity;
  final int freeSpaces;
  final int reservedSpaces;
  final int occupiedSpaces;

  Cemetery({
    required this.id,
    required this.name,
    required this.description,
    required this.country,
    required this.city,
    required this.streetName,
    this.nameKz,
    this.descriptionKz,
    required this.phone,
    required this.locationCoords,
    required this.polygonCoordinates,
    required this.religion,
    required this.burialPrice,
    required this.status,
    required this.capacity,
    required this.freeSpaces,
    required this.reservedSpaces,
    required this.occupiedSpaces,
  });

  factory Cemetery.fromJson(Map<String, dynamic> json) {
    final polygonData = json['polygon_data'];
    final List<List<double>> coordinates = polygonData != null && polygonData['coordinates'] != null
        ? (polygonData['coordinates'] as List)
            .map((coord) => List<double>.from(coord))
            .toList()
        : [];

    return Cemetery(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      country: json['country'],
      city: json['city'],
      streetName: json['street_name'],
      nameKz: json['name_kz'],
      descriptionKz: json['description_kz'],
      phone: json['phone'],
      locationCoords: List<double>.from(json['location_coords']),
      polygonCoordinates: coordinates,
      religion: json['religion'],
      burialPrice: json['burial_price'],
      status: json['status'],
      capacity: json['capacity'],
      freeSpaces: json['free_spaces'],
      reservedSpaces: json['reserved_spaces'],
      occupiedSpaces: json['occupied_spaces'],
    );
  }

  bool get isClosed => freeSpaces == 0;
}
