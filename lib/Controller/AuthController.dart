import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../Network/NetworkServices.dart';
import '../Network/api_client.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class AdminAuthController extends GetxController {


  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString errorMessage = ''.obs;

  // Admin credentials (in production, these should come from backend)
  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  void togglePasswordVisibility(){
    isPasswordVisible.value = !isPasswordVisible.value;
    update();
  }


  final ApiClient api = ApiClient(http.Client());

  // Store response data
  Map<String, dynamic>? driverData;

  // -----------------------
  // DRIVER LOGIN
  // -----------------------
  Future<bool> login(
    String email,
   String password,
  ) async {
    try {
      print("your in login now ");
      isLoading.value = true;
      update();

      // Validate credentials
      if (email.isEmpty || password.isEmpty) {
        errorMessage.value = 'Please fill all fields';
        return false;
      }

      // if (email != _adminEmail || password != _adminPassword) {
      //   errorMessage.value = 'Invalid email or password';
      //   return false;
      // }


      final url = "${NetworkServices.endpoint}/login";
      print(url);

      final response = await api.postRequest(
        url,
        body: {
          "email": email,
          "password": password,
        },
      );

      final data = jsonDecode(response.body);
      print("data is here ${data}");
      driverData = data;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token',  data["accessToken"]?? '');
      await prefs.setBool('isAdminLoggedIn', true);
      token = await prefs.getString('token');
      isLoading.value = false;
      update();

      return true;

    } catch (e) {
      isLoading.value = false;

      errorMessage.value = 'An error occurred: $e';
      update();
      return false;

    }
  }

  Future<bool> Me(
      ) async {
    try {
      print("your in login now ");
      isLoading.value = true;
      update();

      // // Validate credentials
      // if (email.isEmpty || password.isEmpty) {
      //   errorMessage.value = 'Please fill all fields';
      //   return false;
      // }

      // if (email != _adminEmail || password != _adminPassword) {
      //   errorMessage.value = 'Invalid email or password';
      //   return false;
      // }


      final url = "${NetworkServices.auth}/me";
      print(url);

      final response = await api.getRequest(
        url,
      );

      final data = jsonDecode(response.body);
      print("data is here ${data}");
      isLoading.value = false;
      update();
      Get.offAllNamed('/dashboard');
      return true;

    } catch (e) {
      isLoading.value = false;

      errorMessage.value = 'An error occurred: $e';
      update();
      return false;

    }
  }
  // Check login status
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn.value = prefs.getBool('isAdminLoggedIn') ?? false;
  }

  // Logout function
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAdminLoggedIn');
    await prefs.remove('adminEmail');
    await prefs.remove('token');
    isLoggedIn.value = false;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    Me();
  }
}