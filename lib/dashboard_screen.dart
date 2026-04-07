// admin/views/admin_dashboard.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_responsive_admin_panel/widgets/dashboardview.dart';
import 'package:flutter_responsive_admin_panel/widgets/side_menu.dart';
import 'package:get/get.dart';

import 'Controller/DashboardController.dart';
import 'Controller/adminController.dart';

import 'DashboardWidgets/DriverView.dart';
import 'DashboardWidgets/OrderVeiw.dart';
import 'DashboardWidgets/PaymentDashboard.dart';
import 'DashboardWidgets/SellerDetails.dart';
import 'DashboardWidgets/SellerView.dart';

import 'const/Sockets.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminController adminController = Get.put(AdminController());
  final DashboardController controller = Get.put(DashboardController());
  late StreamSubscription _notificationSub;

  @override
  void initState() {
    super.initState();

    final socketService = Get.find<SocketService>();

    _notificationSub = socketService.notificationStream.listen((notification) {
      // Data is already refreshed globally by SocketService._refreshAllData()
      // controller.fetchDashboardData(silent: true);

      socketService.markAsRead(notification.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return _buildMobileLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            adminController.menuItems[adminController
                .currentIndex
                .value]['title'],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        actions: [

          SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue,
            child: Text('A', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 16),
        ],
      ),
      drawer: _buildDrawer(),
      body: Obx(() => _buildCurrentPage()),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Obx(
            () => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: adminController.isSidebarExpanded.value ? 250 : 70,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(2, 0),
                  ),
                ],
              ),
              child: SideMenu(),
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                _buildTopAppBar(),

                // Main Content Area
                Expanded(child: Obx(() => _buildCurrentPage())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF3B82F6)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Color(0xFF3B82F6),
                    size: 30,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Gas Chahiye',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Admin Panel',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ...List.generate(
            adminController.menuItems.length,
            (index) => Obx(
              () => ListTile(
                leading: Icon(
                  adminController.menuItems[index]['icon'],
                  color:
                      adminController.currentIndex.value == index
                          ? Color(0xFF3B82F6)
                          : Colors.grey[600],
                ),
                title: Text(
                  adminController.menuItems[index]['title'],
                  style: TextStyle(
                    color:
                        adminController.currentIndex.value == index
                            ? Color(0xFF3B82F6)
                            : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing:
                    (adminController.menuItems[index]['notification'] as int) >
                            0
                        ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            (adminController.menuItems[index]['notification']
                                    as int)
                                .toString(),
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        )
                        : null,
                selected: adminController.currentIndex.value == index,
                selectedTileColor: Color(0xFFEFF6FF),
                onTap: () {
                  adminController.changeTab(index);
                  Get.back();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Obx(
            () => Text(
              adminController.menuItems[adminController
                      .currentIndex
                      .value]['title']
                  as String,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Spacer(),

          SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Admin User',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                'Super Admin',
                style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 9, 8, 8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: adminController.currentIndex.value,
        onTap: (index) => adminController.changeTab(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF3B82F6),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: 20),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store, size: 20),
            label: 'Sellers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car, size: 20),
            label: 'Drivers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, size: 20),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments, size: 20),
            label: 'Payments',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    final adminController = Get.find<AdminController>();

    // Check if we should show add driver form
    if (adminController.currentIndex.value == 2 &&
        adminController.isAddingDriver.value) {
      // return AddDriverForm();
    }

    // Check other detail views
    if (adminController.currentIndex.value == 1 &&
        adminController.isViewingSellerDetails.value) {
      return SellerDetailsView(
        sellerId: adminController.selectedSellerId.value,
      );
    }

    if (adminController.currentIndex.value == 2 &&
        adminController.isViewingDriverDetails.value) {
      // Return driver details view
    }

    if (adminController.currentIndex.value == 3 &&
        adminController.isViewingOrderDetails.value) {
      // Return order details view
    }

    // Return main views
    switch (adminController.currentIndex.value) {
      case 0:
        return DashboardView();
      case 1:
        return SellersView();
      case 2:
        return DriversView();
      case 3:
        return OrdersView();
      case 4:
        return PaymentsView();
      default:
        return DashboardView();
    }
  }
}
