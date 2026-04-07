// admin/views/drivers_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../Controller/DriverController.dart';
import '../Controller/adminController.dart';
import '../Models/DriverModel.dart';
import 'AddnewDriver.dart';
import 'DriverDetails.dart';
import '../widgets/animations/fade_in_slide.dart';
import 'DriverColors.dart';

// DriverColors is now imported from DriverColors.dart

class DriversView extends StatelessWidget {
  final DriversController controller = Get.find();
  final AdminController adminController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Check if we should show Add Driver form
      if (adminController.isAddingDriver.value) {
        return AddDriverForm();
      }

      // Check if we should show Driver Details
      if (adminController.isViewingDriverDetails.value) {
        final driver = controller.getDriverById(
          adminController.selectedDriverId.value,
        );
        if (driver != null) {
          return DriverDetailsView(driver: driver);
        } else {
          return Center(child: Text('Driver not found'));
        }
      }

      // Otherwise show the main drivers list
      return Scaffold(
        backgroundColor: DriverColors.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 32),
              FadeInSlide(
                duration: Duration(milliseconds: 600),
                delay: 0.1,
                child: _buildStatsGrid(),
              ),
              SizedBox(height: 32),
              FadeInSlide(
                duration: Duration(milliseconds: 600),
                delay: 0.2,
                child: _buildMainCard(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Drivers',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: DriverColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your delivery fleet and status',
              style: TextStyle(fontSize: 14, color: DriverColors.textSecondary),
            ),
          ],
        ),
        Row(
          children: [
            Obx(
              () =>
                  controller.isLoading.value
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DriverColors.textSecondary,
                        ),
                      )
                      : IconButton(
                        onPressed: () => controller.fetchDrivers(),
                        icon: Icon(
                          Iconsax.refresh,
                          size: 20,
                          color: DriverColors.textPrimary,
                        ),
                        tooltip: 'Refresh',
                      ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: DriverColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {
                  adminController.showAddDriverForm();
                },
                child: Row(
                  children: [
                    Icon(Iconsax.add, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Add Driver',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int cols =
            constraints.maxWidth < 640
                ? 1
                : constraints.maxWidth < 1024
                ? 2
                : 4;

        // Use reactive stats from controller
        int total = controller.totalDriversCount.value;
        int active = controller.onlineDriversCount.value;
        int offline = controller.offlineDriversCount.value;
        int busy = controller.busyDriversCount.value;

        return GridView.count(
          crossAxisCount: cols,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: cols == 1 ? 2.8 : 1.8,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              title: 'Total Drivers',
              value: total.toString(),
              icon: Iconsax.people,
              color: DriverColors.accentBlue,
            ),
            _buildStatCard(
              title: 'Online',
              value: active.toString(),
              icon: Iconsax.wifi,
              color: DriverColors.accentGreen,
            ),
            _buildStatCard(
              title: 'Offline',
              value: offline.toString(),
              icon: Iconsax.wifi_square,
              color: DriverColors.accentGithub, // Using grey/slate for offline
            ),
            _buildStatCard(
              title: 'Busy',
              value: busy.toString(),
              icon: Iconsax.car,
              color: DriverColors.accentOrange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    // If color is grey, it might not have accentGithub, using generic slate
    Color displayColor =
        color == DriverColors.accentGithub ? DriverColors.textSecondary : color;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        border: Border.all(color: DriverColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DriverColors.textSecondary,
                ),
              ),
              Icon(icon, size: 20, color: displayColor),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: DriverColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      decoration: BoxDecoration(
        color: DriverColors.surface,
        border: Border.all(color: DriverColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildSearchBar()),
                    SizedBox(width: 16),
                    _buildFilterDropdown(
                      controller.selectedStatus,
                      controller.statusOptions,
                      Iconsax.filter,
                    ),
                    SizedBox(width: 16),
                    _buildFilterDropdown(
                      controller.selectedZone,
                      controller.zoneOptions,
                      Iconsax.map,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: DriverColors.border),
          _buildDriversTable(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: DriverColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DriverColors.border),
      ),
      child: TextField(
        onChanged: (v) => controller.searchQuery.value = v,
        style: TextStyle(fontSize: 14, color: DriverColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search drivers...',
          hintStyle: TextStyle(color: DriverColors.textSecondary),
          prefixIcon: Icon(
            Iconsax.search_normal,
            size: 16,
            color: DriverColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    RxString selectedValue,
    RxList<String> options,
    IconData icon,
  ) {
    return Obx(
      () => Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: DriverColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: DriverColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue.value,
            onChanged: (v) => selectedValue.value = v!,
            icon: Icon(
              Iconsax.arrow_down_1,
              size: 16,
              color: DriverColors.textSecondary,
            ),
            style: TextStyle(fontSize: 14, color: DriverColors.textPrimary),
            items:
                options
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDriversTable() {
    return Obx(() {
      if (controller.isLoading.value && controller.driversList.isEmpty) {
        return Container(
          height: 300,
          child: Center(
            child: CircularProgressIndicator(color: DriverColors.textPrimary),
          ),
        );
      }

      final drivers = controller.filteredDrivers;
      if (drivers.isEmpty) {
        return Container(
          height: 300,
          child: Center(
            child: Text(
              'No drivers found',
              style: TextStyle(color: DriverColors.textSecondary),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 800),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(DriverColors.background),
            dataRowColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.hovered))
                return DriverColors.background.withOpacity(0.5);
              return DriverColors.surface;
            }),
            dividerThickness: 1,
            horizontalMargin: 24,
            columnSpacing: 40,
            columns: [
              DataColumn(label: _buildHeaderCell('DRIVER')),
              DataColumn(label: _buildHeaderCell('CONTACT')),
              DataColumn(label: _buildHeaderCell('STATUS')),
              DataColumn(label: _buildHeaderCell('ZONE')),
              DataColumn(label: _buildHeaderCell('VEHICLE')),
              DataColumn(label: _buildHeaderCell('ACTIONS')),
            ],
            rows:
                drivers.map((driver) {
                  return DataRow(
                    cells: [
                      DataCell(_buildDriverCell(driver)),
                      DataCell(_buildContactCell(driver)),
                      DataCell(_buildStatusBadge(driver.isActive)),
                      DataCell(
                        Text(
                          driver.zoneObject?.zoneName ?? 'N/A',
                          style: TextStyle(
                            fontSize: 13,
                            color: DriverColors.textSecondary,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          driver.vehicleNumber ?? 'N/A',
                          style: TextStyle(
                            fontSize: 13,
                            color: DriverColors.textSecondary,
                          ),
                        ),
                      ),
                      DataCell(_buildActions(driver)),
                    ],
                  );
                }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: DriverColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDriverCell(Drivers driver) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: DriverColors.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: DriverColors.border),
          ),
          child: Center(
            child: Text(
              driver.fullName != null && driver.fullName!.isNotEmpty
                  ? driver.fullName!.substring(0, 1).toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: DriverColors.textSecondary,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              driver.fullName ?? 'Unknown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DriverColors.textPrimary,
              ),
            ),
            if (driver.cnic != null)
              Text(
                'CNIC: ${driver.cnic}',
                style: TextStyle(
                  fontSize: 11,
                  color: DriverColors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCell(Drivers driver) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          driver.phoneNumber ?? '-',
          style: TextStyle(fontSize: 13, color: DriverColors.textPrimary),
        ),
        Text(
          driver.email ?? '-',
          style: TextStyle(fontSize: 12, color: DriverColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool? isActive) {
    Color bg = isActive == true ? Color(0xFFDCFCE7) : Color(0xFFFEE2E2);
    Color text = isActive == true ? Color(0xFF15803D) : Color(0xFFB91C1C);
    String label = isActive == true ? 'Online' : 'Offline';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(Drivers driver) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            driver.isActive == true
                ? Iconsax.toggle_on_circle
                : Iconsax.toggle_off_circle,
            color:
                driver.isActive == true
                    ? DriverColors.accentGreen
                    : DriverColors.textSecondary,
            size: 20,
          ),
          onPressed: () {
            controller.toggleDriverStatus(driver);
          },
          tooltip: 'Toggle Status',
        ),
        PopupMenuButton(
          icon: Icon(Iconsax.more, size: 16, color: DriverColors.textSecondary),
          elevation: 2,
          color: Colors.white,
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Iconsax.eye, size: 16),
                      SizedBox(width: 8),
                      Text("View Details", style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      adminController.showDriverDetails(driver.sId!);
                    });
                  },
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Iconsax.trash, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        "Delete",
                        style: TextStyle(fontSize: 13, color: Colors.red),
                      ),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      controller.deleteDriver(driver.sId!);
                    });
                  },
                ),
              ],
        ),
      ],
    );
  }
}
