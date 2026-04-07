import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../Controller/adminController.dart';

// Tailwind-like Color Palette (Slate/Zinc) - Duplicate for local use to ensure standalone functionality
class SideMenuColors {
  static const Color background = Colors.white;
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color activeBackground = Color(0xFFF1F5F9); // Slate 100
  static const Color activeText = Color(0xFF0F172A); // Slate 900
}

class SideMenu extends StatelessWidget {
  final AdminController controller = Get.find<AdminController>();

  SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SideMenuColors.background,
        border: Border(right: BorderSide(color: SideMenuColors.border)),
      ),
      child: Column(
        children: [
          // Logo Section
          _buildLogo(),

          const SizedBox(height: 16),

          // Menu Items
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.menuItems.length,
                itemBuilder: (context, index) {
                  final item = controller.menuItems[index];
                  return _buildMenuItem(
                    index,
                    item['title'] as String,
                    item['icon'] as IconData,
                    item['notification'] as int,
                  );
                },
              );
            }),
          ),

          // Bottom User Profile
          _buildUserProfile(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Obx(() {
      final isExpanded = controller.isSidebarExpanded.value;
      return Container(
        height: 80,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment:
              isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SideMenuColors.textPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Iconsax.gas_station,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              const Text(
                'Gas Chahiye',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SideMenuColors.textPrimary,
                  fontFamily: 'Poppins',
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildMenuItem(
    int index,
    String title,
    IconData icon,
    int notification,
  ) {
    return Obx(() {
      final isSelected = controller.currentIndex.value == index;
      final isExpanded = controller.isSidebarExpanded.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.changeTab(index),
            borderRadius: BorderRadius.circular(8),
            hoverColor: SideMenuColors.activeBackground.withOpacity(0.5),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? SideMenuColors.activeBackground
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment:
                    isExpanded
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color:
                        isSelected
                            ? SideMenuColors.activeText
                            : SideMenuColors.textTertiary,
                  ),
                  if (isExpanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected
                                  ? SideMenuColors.activeText
                                  : SideMenuColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (notification > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: SideMenuColors.textPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notification.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildUserProfile() {
    return Obx(() {
      final isExpanded = controller.isSidebarExpanded.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: SideMenuColors.border)),
        ),
        child: Row(
          mainAxisAlignment:
              isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: SideMenuColors.activeBackground,
              child: const Icon(
                Iconsax.user,
                color: SideMenuColors.textSecondary,
                size: 18,
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin User',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: SideMenuColors.textPrimary,
                      ),
                    ),
                    Text(
                      'super_admin',
                      style: TextStyle(
                        fontSize: 11,
                        color: SideMenuColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Iconsax.logout,
                size: 18,
                color: SideMenuColors.textTertiary,
              ),
            ],
          ],
        ),
      );
    });
  }
}
