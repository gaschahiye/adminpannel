class DriverModel {
  bool? success;
  Data? data;

  DriverModel({this.success, this.data});

  DriverModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Drivers>? drivers;
  Pagination? pagination;

  Data({this.drivers, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['drivers'] != null) {
      drivers = <Drivers>[];
      json['drivers'].forEach((v) {
        drivers!.add(Drivers.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (drivers != null) {
      data['drivers'] = drivers!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Drivers {
  String? sId;
  String? phoneNumber;
  bool? isActive;
  String? fullName;
  String? cnic;
  String? vehicleNumber;

  // /// Can be String OR Object
  // dynamic zone;

  /// Parsed object if zone is Map
  Zone? zoneObject;

  bool? autoAssignOrders;
  String? driverStatus;
  String? createdAt;
  Stats? stats;
  String? email;

  Drivers({
    this.sId,
    this.phoneNumber,
    this.isActive,
    this.fullName,
    this.cnic,
    this.vehicleNumber,
    // this.zone,
    this.zoneObject,
    this.autoAssignOrders,
    this.driverStatus,
    this.createdAt,
    this.stats,
    this.email,
  });

  Drivers.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    sId = json['_id'];
    phoneNumber = json['phoneNumber'];
    isActive = json['isActive'];
    fullName = json['fullName'];
    cnic = json['cnic'];
    vehicleNumber = json['vehicleNumber'];
    // zone = json['zone'];

    // If zone is an object, parse it safely
    if (json['zone'] != null && json['zone'] is Map<String, dynamic>) {
      zoneObject = Zone.fromJson(json['zone']);
    }

    autoAssignOrders = json['autoAssignOrders'];
    driverStatus = json['driverStatus'];
    createdAt = json['createdAt'];
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['phoneNumber'] = phoneNumber;
    data['isActive'] = isActive;
    data['fullName'] = fullName;
    data['cnic'] = cnic;
    data['vehicleNumber'] = vehicleNumber;
    // data['zone'] = zone;
    data['autoAssignOrders'] = autoAssignOrders;
    data['driverStatus'] = driverStatus;
    data['createdAt'] = createdAt;
    if (stats != null) {
      data['stats'] = stats!.toJson();
    }
    data['email'] = email;
    return data;
  }
}

class Zone {
  String? zoneId;
  String? zoneName;
  String? description;
  List<String>? includedAreas;
  CenterPoint? centerPoint;
  int? radiusKm;
  String? radiusExplanation;
  String? example;

  Zone({
    this.zoneId,
    this.zoneName,
    this.description,
    this.includedAreas,
    this.centerPoint,
    this.radiusKm,
    this.radiusExplanation,
    this.example,
  });

  Zone.fromJson(Map<String, dynamic> json) {
    zoneId = json['zoneId'];
    zoneName = json['zoneName'];
    description = json['description'];
    includedAreas =
        json['includedAreas'] != null
            ? List<String>.from(json['includedAreas'])
            : [];
    centerPoint =
        json['centerPoint'] != null
            ? CenterPoint.fromJson(json['centerPoint'])
            : null;
    radiusKm = json['radiusKm'];
    radiusExplanation = json['radiusExplanation'];
    example = json['example'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['zoneId'] = zoneId;
    data['zoneName'] = zoneName;
    data['description'] = description;
    data['includedAreas'] = includedAreas;
    if (centerPoint != null) {
      data['centerPoint'] = centerPoint!.toJson();
    }
    data['radiusKm'] = radiusKm;
    data['radiusExplanation'] = radiusExplanation;
    data['example'] = example;
    return data;
  }
}

class CenterPoint {
  double? latitude;
  double? longitude;
  String? explanation;

  CenterPoint({this.latitude, this.longitude, this.explanation});

  CenterPoint.fromJson(Map<String, dynamic> json) {
    latitude = (json['latitude'] as num?)?.toDouble();
    longitude = (json['longitude'] as num?)?.toDouble();
    explanation = json['explanation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['explanation'] = explanation;
    return data;
  }
}

class Stats {
  int? totalOrders;
  int? deliveredOrders;
  int? currentAssignedOrders;
  int? deliveryRate;
  int? averageRating;
  int? ratingCount;

  Stats({
    this.totalOrders,
    this.deliveredOrders,
    this.currentAssignedOrders,
    this.deliveryRate,
    this.averageRating,
    this.ratingCount,
  });

  Stats.fromJson(Map<String, dynamic> json) {
    totalOrders = json['totalOrders'];
    deliveredOrders = json['deliveredOrders'];
    currentAssignedOrders = json['currentAssignedOrders'];
    deliveryRate = json['deliveryRate'];
    averageRating = json['averageRating'];
    ratingCount = json['ratingCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['totalOrders'] = totalOrders;
    data['deliveredOrders'] = deliveredOrders;
    data['currentAssignedOrders'] = currentAssignedOrders;
    data['deliveryRate'] = deliveryRate;
    data['averageRating'] = averageRating;
    data['ratingCount'] = ratingCount;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalDrivers;
  int? limit;
  bool? hasNext;
  bool? hasPrev;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalDrivers,
    this.limit,
    this.hasNext,
    this.hasPrev,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
    totalDrivers = json['totalDrivers'];
    limit = json['limit'];
    hasNext = json['hasNext'];
    hasPrev = json['hasPrev'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['currentPage'] = currentPage;
    data['totalPages'] = totalPages;
    data['totalDrivers'] = totalDrivers;
    data['limit'] = limit;
    data['hasNext'] = hasNext;
    data['hasPrev'] = hasPrev;
    return data;
  }
}
