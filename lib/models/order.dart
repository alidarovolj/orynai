import 'product.dart';

class Order {
  final int id;
  final String userPhone;
  final String status;
  final int totalPrice;
  final List<OrderItem> items;
  final String createdAt;
  final String updatedAt;
  final UserInfo userInfo;

  Order({
    required this.id,
    required this.userPhone,
    required this.status,
    required this.totalPrice,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    required this.userInfo,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final itemsList = itemsRaw is List
        ? (itemsRaw).map((item) => OrderItem.fromJson(item as Map<String, dynamic>)).toList()
        : <OrderItem>[];
    return Order(
      id: json['id'] as int,
      userPhone: json['user_phone'] as String,
      status: json['status'] as String,
      totalPrice: json['total_price'] as int,
      items: itemsList,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      userInfo: UserInfo.fromJson(json['user_info'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_phone': userPhone,
      'status': status,
      'total_price': totalPrice,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_info': userInfo.toJson(),
    };
  }

  String get statusText {
    switch (status) {
      case 'pending_payment':
        return 'Ожидает оплаты';
      case 'paid':
        return 'Оплачен';
      case 'in_progress':
        return 'В процессе';
      case 'completed':
        return 'Завершен';
      case 'cancelled':
        return 'Отменен';
      default:
        return status;
    }
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final int price;
  final String status;
  final String deliveryDestinationAddress;
  final String deliveryArrivalTime;
  final Product product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.status,
    required this.deliveryDestinationAddress,
    required this.deliveryArrivalTime,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      price: json['price'] as int,
      status: json['status'] as String,
      deliveryDestinationAddress: json['delivery_destination_address'] as String,
      deliveryArrivalTime: json['delivery_arrival_time'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'status': status,
      'delivery_destination_address': deliveryDestinationAddress,
      'delivery_arrival_time': deliveryArrivalTime,
      'product': product.toJson(),
    };
  }

  int get totalPrice => price * quantity;
}

class UserInfo {
  final int id;
  final String? name;
  final String? surname;
  final String? patronymic;
  final String? iin;
  final String phone;

  UserInfo({
    required this.id,
    this.name,
    this.surname,
    this.patronymic,
    this.iin,
    required this.phone,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int,
      name: json['name']?.toString(),
      surname: json['surname']?.toString(),
      patronymic: json['patronymic']?.toString(),
      iin: json['iin']?.toString(),
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'patronymic': patronymic,
      'iin': iin,
      'phone': phone,
    };
  }
}

class OrdersResponse {
  final List<Order> items;
  final int totalCount;
  final int page;
  final int totalPages;
  final int limit;

  OrdersResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    required this.limit,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      items: (json['items'] as List)
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
      page: json['page'] as int,
      totalPages: json['total_pages'] as int,
      limit: json['limit'] as int,
    );
  }
}
