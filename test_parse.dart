import 'dart:convert';
import 'lib/Models/DriverModel.dart';

void main() {
  const jsonStr = '''{"zone":{"includedAreas":[]},"_id":"692cd10d4ff52dcfb59bd9fb","phoneNumber":"+923325417662","email":"inamk@gmail.com","isActive":true,"fullName":"inam","cnic":"11101-2312131-2","autoAssignOrders":true,"driverStatus":"busy","createdAt":"2025-11-30T23:19:41.437Z","locations":[],"id":"692cd10d4ff52dcfb59bd9fb","stats":{"assignedOrders":0,"deliveredOrders":0}}''';
  final Map<String, dynamic> data = jsonDecode(jsonStr);
  final driver = Drivers.fromJson(data);
  print('Result email: ${driver.email}');
}
