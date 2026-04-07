import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login/login.dart';
import 'const/AppBindings.dart';
import 'dashboard_screen.dart';

var token;
var prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();
  token = prefs.getString('token');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,

      // ✅ GetMaterialApp goes in CHILD
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gas Chahiye Admin',

        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          fontFamily: 'Inter',
        ),

        // ✅ Bindings only ONCE
        initialBinding: AdminBindings(),
        // home: const PaymentDashboardScreen(),
        initialRoute: '/login',
        getPages: [
          GetPage(name: '/login', page: () => AdminLoginScreen()),
          GetPage(name: '/dashboard', page: () => AdminDashboard()),
        ],
      ),
    );
  }
}
