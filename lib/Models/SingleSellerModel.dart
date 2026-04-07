// seller_response_model.dart
// Fully copy-paste ready

class SellerResponse {
  final bool success;
  final Seller? seller;

  SellerResponse({
    required this.success,
    this.seller,
  });

  factory SellerResponse.fromJson(Map<String, dynamic> json) {
    return SellerResponse(
      success: json['success'] ?? false,
      seller:
      json['seller'] != null ? Seller.fromJson(json['seller']) : null,
    );
  }
}

class Seller {
  final String id;
  final String role;
  final String phoneNumber;
  final String orgaLicenseFile;
  final bool isActive;
  final bool isVerified;
  final String language;
  final String businessName;
  final String orgaLicenseNumber;
  final DateTime? orgaExpDate;
  final String ntnNumber;
  final String sellerStatus;
  final bool autoAssignOrders;
  final String driverStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Rating rating;
  final SellerStats stats;
  final List<SellerLocation> locations;
  final List<Inventory> inventory;

  Seller({
    required this.id,
    required this.role,
    required this.phoneNumber,
    required this.orgaLicenseFile,
    required this.isActive,
    required this.isVerified,
    required this.language,
    required this.businessName,
    required this.orgaLicenseNumber,
    this.orgaExpDate,
    required this.ntnNumber,
    required this.sellerStatus,
    required this.autoAssignOrders,
    required this.driverStatus,
    this.createdAt,
    this.updatedAt,
    required this.rating,
    required this.stats,
    required this.locations,
    required this.inventory,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['_id'] ?? '',
      role: json['role'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      orgaLicenseFile: json['orgaLicenseFile'] ?? '',
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? false,
      language: json['language'] ?? '',
      businessName: json['businessName'] ?? '',
      orgaLicenseNumber: json['orgaLicenseNumber'] ?? '',
      orgaExpDate: json['orgaExpDate'] != null
          ? DateTime.parse(json['orgaExpDate'])
          : null,
      ntnNumber: json['ntnNumber'] ?? '',
      sellerStatus: json['sellerStatus'] ?? '',
      autoAssignOrders: json['autoAssignOrders'] ?? false,
      driverStatus: json['driverStatus'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      rating: Rating.fromJson(json['rating'] ?? {}),
      stats: SellerStats.fromJson(json['stats'] ?? {}),
      locations: (json['locations'] as List<dynamic>? ?? [])
          .map((e) => SellerLocation.fromJson(e))
          .toList(),
      inventory: (json['inventory'] as List<dynamic>? ?? [])
          .map((e) => Inventory.fromJson(e))
          .toList(),
    );
  }
}

class Rating {
  final double average;
  final int count;

  Rating({
    required this.average,
    required this.count,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      average: (json['average'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

class SellerStats {
  final int totalOrders;
  final int completedOrders;
  final double totalRevenue;
  final double averageRating;
  final int ratingCount;

  SellerStats({
    required this.totalOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.averageRating,
    required this.ratingCount,
  });

  factory SellerStats.fromJson(Map<String, dynamic> json) {
    return SellerStats(
      totalOrders: json['totalOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
    );
  }
}

class SellerLocation {
  final String id;
  final String warehouseName;
  final String city;
  final String address;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SellerLocation({
    required this.id,
    required this.warehouseName,
    required this.city,
    required this.address,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SellerLocation.fromJson(Map<String, dynamic> json) {
    return SellerLocation(
      id: json['_id'] ?? '',
      warehouseName: json['warehouseName'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

class Inventory {
  final String id;
  final String location;
  final String city;
  final int pricePerKg;
  final bool isRefund;
  final int totalInventory;
  final int issuedCylinders;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, Cylinder> cylinders;
  final List<AddOn> addOns;

  Inventory({
    required this.id,
    required this.location,
    required this.city,
    required this.pricePerKg,
    required this.isRefund,
    required this.totalInventory,
    required this.issuedCylinders,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required this.cylinders,
    required this.addOns,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['_id'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      pricePerKg: json['pricePerKg'] ?? 0,
      isRefund: json['isRefund'] ?? false,
      totalInventory: json['totalInventory'] ?? 0,
      issuedCylinders: json['issuedCylinders'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      cylinders: (json['cylinders'] as Map<String, dynamic>? ?? {})
          .map((key, value) =>
          MapEntry(key, Cylinder.fromJson(value))),
      addOns: (json['addOns'] as List<dynamic>? ?? [])
          .map((e) => AddOn.fromJson(e))
          .toList(),
    );
  }
}

class Cylinder {
  final int quantity;
  final int price;

  Cylinder({
    required this.quantity,
    required this.price,
  });

  factory Cylinder.fromJson(Map<String, dynamic> json) {
    return Cylinder(
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
    );
  }
}

class AddOn {
  final String id;
  final String title;
  final int price;
  final int discount;
  final int quantity;

  AddOn({
    required this.id,
    required this.title,
    required this.price,
    required this.discount,
    required this.quantity,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? 0,
      discount: json['discount'] ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }
}
