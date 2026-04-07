import 'dart:convert';
import 'lib/Models/DriverModel.dart';
void main() {
  const jsonStr = '''{"success":true,"drivers":[{"_id":"1","email":"inamk@gmail.com","phoneNumber":"+123"}]}''';
  final Map<String, dynamic> data = jsonDecode(jsonStr);
  final List<dynamic> driversJson = data['drivers'];
  final List<Drivers> driversList = driversJson.map((json) => Drivers.fromJson(json)).toList();
  print('First driver email: ${driversList.first.email}');
}
