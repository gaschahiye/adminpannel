import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../const/Sockets.dart';
import '../Controller/DashboardController.dart';
import '../Controller/sellercontroller.dart';
import '../Controller/AuthController.dart';
import '../dashboard_screen.dart';

class AdminLoginScreen extends StatelessWidget {
  final AdminAuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background with gradient and subtle pattern
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.blue.shade50,
                      Colors.purple.shade50,
                    ],
                  ),
                ),
                child: CustomPaint(painter: _BackgroundPainter()),
              ),

              // Main Content
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? 500 : 1000,
                      ),
                      child:
                          isMobile
                              ? _buildMobileLayout(formkey)
                              : _buildDesktopLayout(formkey),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(formkey) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side - Branding and Info
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Welcome to',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  'Admin Portal',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    background:
                        Paint()
                          ..shader = const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                    color: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Manage your entire platform with powerful tools and real-time analytics. Secure access with enterprise-grade authentication.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                _buildFeaturesGrid(),
              ],
            ),
          ),
        ),

        // Right side - Login Form
        Expanded(flex: 4, child: _buildLoginForm(formkey)),
      ],
    );
  }

  Widget _buildMobileLayout(formkey) {
    return Column(
      children: [
        // Header Section
        Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  size: 35,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Admin Portal',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sign in to your account',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Login Form
        _buildLoginForm(formkey),
      ],
    );
  }

  Widget _buildLoginForm(formKey) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.8),
            blurRadius: 40,
            spreadRadius: 10,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign In',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your credentials to continue',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),

            // Email Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email Address',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'admin@example.com',
                    hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade400),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(left: 16, right: 12),
                      child: Icon(
                        Iconsax.sms,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Password Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => TextFormField(
                    controller: passwordController,
                    obscureText: !authController.isPasswordVisible.value,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.only(left: 16, right: 12),
                        child: Icon(
                          Iconsax.lock,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: IconButton(
                          icon: Icon(
                            authController.isPasswordVisible.value
                                ? Iconsax.eye
                                : Iconsax.eye_slash,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () {
                            authController.togglePasswordVisibility();
                          },
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Remember Me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Obx(
                        () => Transform.scale(
                          scale: 0.9,
                          child: Checkbox(
                            value: authController.rememberMe.value,
                            onChanged: (value) {
                              authController.rememberMe.value = value!;
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: BorderSide(color: Colors.grey.shade400),
                            activeColor: const Color(0xFF667eea),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          'Remember me',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Forgot password
                    Get.snackbar(
                      'Feature Coming Soon',
                      'Password recovery will be available soon.',
                      backgroundColor: Colors.blue.shade50,
                      colorText: Colors.blue.shade800,
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF667eea),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Sign In Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      authController.isLoading.value
                          ? null
                          : () async {
                            if (formKey.currentState!.validate()) {
                              final success = await authController.login(
                                emailController.text.trim(),
                                passwordController.text,
                              );
                              if (success) {
                                // Refresh Data & Reconnect Sockets
                                try {
                                  debugPrint(
                                    "Login successful. Refreshing data...",
                                  );

                                  // 1. Refresh Dashboard
                                  if (Get.isRegistered<DashboardController>()) {
                                    Get.find<DashboardController>()
                                        .refreshData();
                                  }

                                  // 2. Refresh Sellers
                                  if (Get.isRegistered<SellersController>()) {
                                    Get.find<SellersController>()
                                        .fetchSellers();
                                  }

                                  // 3. Connect Socket with new token
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final String? token = prefs.getString(
                                    'token',
                                  );
                                  if (token != null &&
                                      Get.isRegistered<SocketService>()) {
                                    Get.find<SocketService>().connect(token);
                                  }
                                } catch (e) {
                                  debugPrint(
                                    "Error triggering post-login updates: $e",
                                  );
                                }

                                Get.offAllNamed('/dashboard');
                                // Get.snackbar(
                                //   'Welcome Admin!',
                                //   'Login successful',
                                //   backgroundColor: Colors.green,
                                //   colorText: Colors.white,
                                //   snackPosition: SnackPosition.BOTTOM,
                                // );
                              }
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    shadowColor: const Color(0xFF667eea).withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      authController.isLoading.value
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Iconsax.arrow_right_3, size: 18),
                            ],
                          ),
                ),
              ),
            ),

            // Error Message
            Obx(
              () =>
                  authController.errorMessage.value.isNotEmpty
                      ? Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.info_circle,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                authController.errorMessage.value,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : const SizedBox(),
            ),

            const SizedBox(height: 30),

            // Footer
            Center(
              child: Text(
                '© ${DateTime.now().year} Admin Panel. All rights reserved.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _buildFeatureItem(
          icon: Iconsax.shield_tick,
          title: 'Secure Login',
          color: Colors.green,
        ),
        _buildFeatureItem(
          icon: Iconsax.chart_2,
          title: 'Real-time Analytics',
          color: Colors.blue,
        ),
        _buildFeatureItem(
          icon: Iconsax.setting,
          title: 'Easy Management',
          color: Colors.purple,
        ),
        _buildFeatureItem(
          icon: Iconsax.activity,
          title: 'Performance',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Background Painter for subtle pattern
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue.shade100.withOpacity(0.03)
          ..style = PaintingStyle.fill;

    // Draw circles pattern
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * (0.2 + i * 0.15)),
        size.width * 0.1,
        paint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * (0.3 + i * 0.2)),
        size.width * 0.08,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
