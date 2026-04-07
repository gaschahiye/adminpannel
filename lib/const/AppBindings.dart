// admin/bindings.dart
import 'package:get/get.dart';

import '../Controller/AuthController.dart';
import '../Controller/DashboardController.dart';
import '../Controller/DriverController.dart';
import '../Controller/ZonesController.dart';
import '../Controller/adminController.dart';
import '../Controller/orderController.dart';
import '../Controller/PaymentController.dart';
import '../Controller/sellercontroller.dart';
import '../Services/PaymentService.dart';
import 'Sockets.dart';

class AdminBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AdminController());
    Get.put(DashboardController());
    Get.put(SellersController());
    Get.lazyPut(() => DriversController());
    Get.lazyPut(() => OrdersController());
    Get.put<AdminAuthController>(
      AdminAuthController(),
      // 🔑 VERY IMPORTANT
    );
    Get.lazyPut(() => ZonesService(), fenix: true);
    Get.lazyPut(() => SocketService(), fenix: true);
    Get.put(PaymentService());
    Get.put(PaymentController());
  }
}
