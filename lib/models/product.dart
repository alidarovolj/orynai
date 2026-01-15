class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final String supplierPhone;
  final int categoryId;
  final String status;
  final int deliveryMethodId;
  final String createdAt;
  final String updatedAt;
  final String type; // "product" или "service"
  final List<String> imageUrls;
  final bool availability;
  final String country;
  final String city;
  final String serviceTime;
  final DeliveryMethod? deliveryMethod;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.supplierPhone,
    required this.categoryId,
    required this.status,
    required this.deliveryMethodId,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    required this.imageUrls,
    required this.availability,
    required this.country,
    required this.city,
    required this.serviceTime,
    this.deliveryMethod,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      supplierPhone: json['supplier_phone'] as String,
      categoryId: json['category_id'] as int,
      status: json['status'] as String,
      deliveryMethodId: json['delivery_method_id'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      type: json['type'] as String,
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      availability: json['availability'] as bool? ?? true,
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      serviceTime: json['service_time'] as String? ?? '',
      deliveryMethod: json['delivery_method'] != null
          ? DeliveryMethod.fromJson(
              json['delivery_method'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'supplier_phone': supplierPhone,
      'category_id': categoryId,
      'status': status,
      'delivery_method_id': deliveryMethodId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'type': type,
      'image_urls': imageUrls,
      'availability': availability,
      'country': country,
      'city': city,
      'service_time': serviceTime,
      'delivery_method': deliveryMethod?.toJson(),
    };
  }
}

class DeliveryMethod {
  final int id;
  final String name;
  final String description;
  final String createdAt;
  final String updatedAt;

  DeliveryMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryMethod.fromJson(Map<String, dynamic> json) {
    return DeliveryMethod(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ProductsResponse {
  final List<Product> items;
  final int totalCount;
  final int page;
  final int totalPages;
  final int limit;

  ProductsResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    required this.limit,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      limit: json['limit'] as int? ?? 12,
    );
  }
}
