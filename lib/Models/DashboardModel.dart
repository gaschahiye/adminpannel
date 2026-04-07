class DashboardModel {
  bool? success;
  Stats? stats;

  DashboardModel({this.success, this.stats});

  DashboardModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    stats = json['stats'] != null ? new Stats.fromJson(json['stats']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.stats != null) {
      data['stats'] = this.stats!.toJson();
    }
    return data;
  }
}

class Stats {
  int? totalSellers;
  int? totalOrders;
  int? totalRevenue;
  int? activeDrivers;
  List<MonthlyOrderData>? monthlyOrderData;
  List<OrderStatusData>? orderStatusData;
  List<RecentNotifications>? recentNotifications;
  Debug? dDebug;

  Stats(
      {this.totalSellers,
        this.totalOrders,
        this.totalRevenue,
        this.activeDrivers,
        this.monthlyOrderData,
        this.orderStatusData,
        this.recentNotifications,
        this.dDebug});

  Stats.fromJson(Map<String, dynamic> json) {
    totalSellers = json['totalSellers'];
    totalOrders = json['totalOrders'];
    totalRevenue = json['totalRevenue'];
    activeDrivers = json['activeDrivers'];
    if (json['monthlyOrderData'] != null) {
      monthlyOrderData = <MonthlyOrderData>[];
      json['monthlyOrderData'].forEach((v) {
        monthlyOrderData!.add(new MonthlyOrderData.fromJson(v));
      });
    }
    if (json['orderStatusData'] != null) {
      orderStatusData = <OrderStatusData>[];
      json['orderStatusData'].forEach((v) {
        orderStatusData!.add(new OrderStatusData.fromJson(v));
      });
    }
    if (json['recentNotifications'] != null) {
      recentNotifications = <RecentNotifications>[];
      json['recentNotifications'].forEach((v) {
        recentNotifications!.add(new RecentNotifications.fromJson(v));
      });
    }
    dDebug = json['_debug'] != null ? new Debug.fromJson(json['_debug']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalSellers'] = this.totalSellers;
    data['totalOrders'] = this.totalOrders;
    data['totalRevenue'] = this.totalRevenue;
    data['activeDrivers'] = this.activeDrivers;
    if (this.monthlyOrderData != null) {
      data['monthlyOrderData'] =
          this.monthlyOrderData!.map((v) => v.toJson()).toList();
    }
    if (this.orderStatusData != null) {
      data['orderStatusData'] =
          this.orderStatusData!.map((v) => v.toJson()).toList();
    }
    if (this.recentNotifications != null) {
      data['recentNotifications'] =
          this.recentNotifications!.map((v) => v.toJson()).toList();
    }
    if (this.dDebug != null) {
      data['_debug'] = this.dDebug!.toJson();
    }
    return data;
  }
}

class MonthlyOrderData {
  String? month;
  int? orders;

  MonthlyOrderData({this.month, this.orders});

  MonthlyOrderData.fromJson(Map<String, dynamic> json) {
    month = json['month'];
    orders = json['orders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['month'] = this.month;
    data['orders'] = this.orders;
    return data;
  }
}

class OrderStatusData {
  String? status;
  int? count;
  double? percentage;

  OrderStatusData({this.status, this.count, this.percentage});

  OrderStatusData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    count = json['count'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['count'] = this.count;
    data['percentage'] = this.percentage;
    return data;
  }
}

class RecentNotifications {
  String? id;
  String? title;
  String? message;
  String? type;
  bool? isRead;
  String? createdAt;
  User? user;

  RecentNotifications(
      {this.id,
        this.title,
        this.message,
        this.type,
        this.isRead,
        this.createdAt,
        this.user});

  RecentNotifications.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    message = json['message'];
    type = json['type'];
    isRead = json['isRead'];
    createdAt = json['createdAt'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['message'] = this.message;
    data['type'] = this.type;
    data['isRead'] = this.isRead;
    data['createdAt'] = this.createdAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? name;
  String? role;

  User({this.name, this.role});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['role'] = this.role;
    return data;
  }
}

class Debug {
  int? totalOrders;
  RevenueBreakdown? revenueBreakdown;

  Debug({this.totalOrders, this.revenueBreakdown});

  Debug.fromJson(Map<String, dynamic> json) {
    totalOrders = json['totalOrders'];
    revenueBreakdown = json['revenueBreakdown'] != null
        ? new RevenueBreakdown.fromJson(json['revenueBreakdown'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalOrders'] = this.totalOrders;
    if (this.revenueBreakdown != null) {
      data['revenueBreakdown'] = this.revenueBreakdown!.toJson();
    }
    return data;
  }
}

class RevenueBreakdown {
  int? total;
  int? fromCompletedPayments;
  int? fromPendingPayments;

  RevenueBreakdown(
      {this.total, this.fromCompletedPayments, this.fromPendingPayments});

  RevenueBreakdown.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    fromCompletedPayments = json['fromCompletedPayments'];
    fromPendingPayments = json['fromPendingPayments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['fromCompletedPayments'] = this.fromCompletedPayments;
    data['fromPendingPayments'] = this.fromPendingPayments;
    return data;
  }
}
