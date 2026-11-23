/// Shipping address payload used in `POST /order` and returned inside `OrderModel`.
class ShippingAddress {
  final String fullName;
  final String address;
  final String city;
  final String postalCode;
  final String phone;

  const ShippingAddress({
    required this.fullName,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.phone,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: (json['full_name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      postalCode: (json['postal_code'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'phone': phone,
    };
  }
}

/// Summary line item inside an order.
class OrderItemSummary {
  final String title;
  final int quantity;
  final double price;

  const OrderItemSummary({
    required this.title,
    required this.quantity,
    required this.price,
  });

  factory OrderItemSummary.fromJson(Map<String, dynamic> json) {
    final rawProduct = json['product'];
    String title = (json['title'] ?? '').toString();
    double price = _parseDouble(json['price'] ?? json['current_price']);

    if (rawProduct is Map<String, dynamic>) {
      if (title.isEmpty) {
        title = (rawProduct['title'] ?? 'Product').toString();
      }
      if (price == 0) {
        price = _parseDouble(rawProduct['current_price']);
      }
    } else if (title.isEmpty) {
      title = 'Product';
    }

    int qty = 1;
    final rawQty = json['quantity'];
    if (rawQty is num) {
      qty = rawQty.toInt();
    } else if (rawQty != null) {
      qty = int.tryParse(rawQty.toString()) ?? 1;
    }

    return OrderItemSummary(
      title: title,
      quantity: qty,
      price: price,
    );
  }

  static double _parseDouble(dynamic val) {
    if (val is num) return val.toDouble();
    if (val == null) return 0;
    return double.tryParse(val.toString()) ?? 0;
  }
}

/// Customer order model (`GET /orders`, `POST /order`, `PATCH /orders/:id/cancel`).
class OrderModel {
  final String id;
  final String status;
  final String paymentMethod;
  final double totalAmount;
  final ShippingAddress? shippingAddress;
  final List<OrderItemSummary> items;
  final DateTime? createdAt;
  final String? paymentUrl;

  const OrderModel({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.totalAmount,
    this.shippingAddress,
    required this.items,
    this.createdAt,
    this.paymentUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    ShippingAddress? addr;
    if (json['shipping_address'] is Map<String, dynamic>) {
      addr = ShippingAddress.fromJson(
        json['shipping_address'] as Map<String, dynamic>,
      );
    }

    final parsedItems = <OrderItemSummary>[];
    final rawItems = json['items'] ?? json['products'];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map<String, dynamic>) {
          parsedItems.add(OrderItemSummary.fromJson(item));
        }
      }
    }

    double total = 0;
    final rawTotal = json['total_amount'] ?? json['total'] ?? json['amount'];
    if (rawTotal is num) {
      total = rawTotal.toDouble();
    } else if (rawTotal != null) {
      total = double.tryParse(rawTotal.toString()) ?? 0;
    }
    if (total == 0 && parsedItems.isNotEmpty) {
      total = parsedItems.fold(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );
    }

    return OrderModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      paymentMethod: (json['payment_method'] ?? 'cod').toString(),
      totalAmount: total,
      shippingAddress: addr,
      items: parsedItems,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      paymentUrl: json['payment_url']?.toString() ??
          json['GatewayPageURL']?.toString(),
    );
  }
}
