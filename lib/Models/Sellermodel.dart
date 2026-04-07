class SellerModel {
  bool? success;
  List<Sellers>? sellers;
  Pagination? pagination;

  SellerModel({this.success, this.sellers, this.pagination});

  SellerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['sellers'] != null) {
      sellers = <Sellers>[];
      json['sellers'].forEach((v) {
        sellers!.add(new Sellers.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.sellers != null) {
      data['sellers'] = this.sellers!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Sellers {
  String? sId;
  String? phoneNumber;
  String? businessName;
  String? orgaLicenseNumber;
  String? sellerStatus;
  String? createdAt;
  List<Locations>? locations;
  String? id;
  Stats? stats;
  String? email;

  Sellers(
      {this.sId,
        this.phoneNumber,
        this.businessName,
        this.orgaLicenseNumber,
        this.sellerStatus,
        this.createdAt,
        this.locations,
        this.id,
        this.stats,
        this.email});

  Sellers.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    phoneNumber = json['phoneNumber'];
    businessName = json['businessName'];
    orgaLicenseNumber = json['orgaLicenseNumber'];
    sellerStatus = json['sellerStatus'];
    createdAt = json['createdAt'];
    if (json['locations'] != null) {
      locations = <Locations>[];
      json['locations'].forEach((v) {
        locations!.add(new Locations.fromJson(v));
      });
    }
    id = json['id'];
    stats = json['stats'] != null ? new Stats.fromJson(json['stats']) : null;
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['phoneNumber'] = this.phoneNumber;
    data['businessName'] = this.businessName;
    data['orgaLicenseNumber'] = this.orgaLicenseNumber;
    data['sellerStatus'] = this.sellerStatus;
    data['createdAt'] = this.createdAt;
    if (this.locations != null) {
      data['locations'] = this.locations!.map((v) => v.toJson()).toList();
    }
    data['id'] = this.id;
    if (this.stats != null) {
      data['stats'] = this.stats!.toJson();
    }
    data['email'] = this.email;
    return data;
  }
}

class Locations {
  Location? location;
  String? sId;
  String? seller;
  String? warehouseName;
  String? city;
  String? address;
  bool? isActive;
  int? iV;
  String? createdAt;
  String? updatedAt;

  Locations(
      {this.location,
        this.sId,
        this.seller,
        this.warehouseName,
        this.city,
        this.address,
        this.isActive,
        this.iV,
        this.createdAt,
        this.updatedAt});

  Locations.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    seller = json['seller'];
    warehouseName = json['warehouseName'];
    city = json['city'];
    address = json['address'];
    isActive = json['isActive'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['_id'] = this.sId;
    data['seller'] = this.seller;
    data['warehouseName'] = this.warehouseName;
    data['city'] = this.city;
    data['address'] = this.address;
    data['isActive'] = this.isActive;
    data['__v'] = this.iV;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}

class Stats {
  int? totalOrders;
  int? completedOrders;
  int? totalInventory;

  Stats({this.totalOrders, this.completedOrders, this.totalInventory});

  Stats.fromJson(Map<String, dynamic> json) {
    totalOrders = json['totalOrders'];
    completedOrders = json['completedOrders'];
    totalInventory = json['totalInventory'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalOrders'] = this.totalOrders;
    data['completedOrders'] = this.completedOrders;
    data['totalInventory'] = this.totalInventory;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalSellers;
  bool? hasNext;

  Pagination(
      {this.currentPage, this.totalPages, this.totalSellers, this.hasNext});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
    totalSellers = json['totalSellers'];
    hasNext = json['hasNext'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    data['totalSellers'] = this.totalSellers;
    data['hasNext'] = this.hasNext;
    return data;
  }
}
