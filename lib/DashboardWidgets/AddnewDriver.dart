// admin/views/add_driver_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../Controller/DriverController.dart';
import '../Controller/ZonesController.dart';
import '../Models/ZoneModel.dart';
import '../widgets/animations/fade_in_slide.dart';
import 'DriverColors.dart';

// DriverColors is now imported from DriverColors.dart

class AddDriverForm extends StatefulWidget {
  @override
  _AddDriverFormState createState() => _AddDriverFormState();
}

class _AddDriverFormState extends State<AddDriverForm> {
  final DriversController _driversController = Get.find<DriversController>();
  final ZonesService _zonesService = Get.find<ZonesService>();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cnicController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _licenseController = TextEditingController();

  Zone? _selectedZone;
  bool _autoAssignOrders = true;
  bool _isPasswordVisible = false;
  bool _isFormSubmitted = false;

  // Validation patterns
  final _cnicRegex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  // Relaxed vehicle regex: Allows letters, numbers, dashes, and spaces, min 3 chars
  final _vehicleRegex = RegExp(r'^[a-zA-Z0-9\-\s]{3,}$');

  @override
  void initState() {
    super.initState();
    if (_zonesService.zones.isEmpty) {
      _zonesService.loadZones();
    }
    _cnicController.addListener(_formatCNIC);
  }

  @override
  void dispose() {
    _cnicController.removeListener(_formatCNIC);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cnicController.dispose();
    _vehicleController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _formatCNIC() {
    final text = _cnicController.text;
    final length = text.length;
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');

    if (length > _cnicController.text.length) return; // Backspace

    if (digitsOnly.length <= 5) {
      _cnicController.value = _cnicController.value.copyWith(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length),
      );
    } else if (digitsOnly.length <= 12) {
      final part1 = digitsOnly.substring(0, 5);
      final part2 = digitsOnly.substring(5);
      _cnicController.value = _cnicController.value.copyWith(
        text: '$part1-$part2',
        selection: TextSelection.collapsed(offset: '$part1-$part2'.length),
      );
    } else if (digitsOnly.length <= 13) {
      final part1 = digitsOnly.substring(0, 5);
      final part2 = digitsOnly.substring(5, 12);
      final part3 = digitsOnly.substring(12);
      _cnicController.value = _cnicController.value.copyWith(
        text: '$part1-$part2-$part3',
        selection: TextSelection.collapsed(
          offset: '$part1-$part2-$part3'.length,
        ),
      );
    }
  }

  void _submitForm() async {
    setState(() => _isFormSubmitted = true);

    if (!_formKey.currentState!.validate()) {
      _showToast('Please check the highlighted fields');
      return;
    }

    if (_selectedZone == null) {
      _showToast('Please select a service zone');
      return;
    }

    await _driversController.addDriver(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      cnic: _cnicController.text.trim(),
      vehicleNumber: _vehicleController.text.trim(),
      zone: _selectedZone!.toJson(),
      autoAssignOrders: _autoAssignOrders,
      licencenumber: _licenseController.text.trim(),
    );
  }

  void _showToast(String message) {
    Get.snackbar(
      'Alert',
      message,
      backgroundColor: Color(0xFFFEF2F2), // Red 50
      colorText: Color(0xFF991B1B), // Red 800
      icon: Icon(Iconsax.warning_2, size: 24, color: Color(0xFF991B1B)),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      boxShadows: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildSectionCard('Personal Information', [
                            _buildFormField(
                              controller: _nameController,
                              label: 'Full Name',
                              hintText: 'John Doe',
                              icon: Iconsax.user,
                              validator:
                                  (v) =>
                                      v!.isEmpty || v.length < 3
                                          ? 'Valid name required'
                                          : null,
                            ),
                            SizedBox(height: 24),
                            _buildFormField(
                              controller: _emailController,
                              label: 'Email Address',
                              hintText: 'john@example.com',
                              icon: Iconsax.sms,
                              validator:
                                  (v) =>
                                      v!.isNotEmpty && !_emailRegex.hasMatch(v)
                                          ? 'Invalid email'
                                          : null,
                              isRequired: false,
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(child: _buildPhoneField()),
                                SizedBox(width: 24),
                                Expanded(child: _buildCNICField()),
                              ],
                            ),
                          ]),
                          SizedBox(height: 24),
                          _buildSectionCard('Vehicle Information', [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    controller: _vehicleController,
                                    label: 'Vehicle Number',
                                    hintText: 'ABC-123',
                                    icon: Iconsax.car,
                                    validator:
                                        (v) =>
                                            v!.isEmpty ||
                                                    !_vehicleRegex.hasMatch(v)
                                                ? 'Invalid format'
                                                : null,
                                  ),
                                ),
                                SizedBox(width: 24),
                                Expanded(
                                  child: _buildFormField(
                                    controller: _licenseController,
                                    label: 'License Number',
                                    hintText: 'LHR-12345',
                                    icon: Iconsax.driver,
                                    validator:
                                        (v) =>
                                            v!.isEmpty
                                                ? 'License required'
                                                : null,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ],
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildSectionCard('Account & Zone', [
                            _buildFormField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: '••••••••',
                              icon: Iconsax.lock,
                              obscureText: true,
                              showVisibilityToggle: true,
                              validator:
                                  (v) => v!.length < 6 ? 'Min 6 chars' : null,
                            ),
                            SizedBox(height: 24),
                            _buildZoneDropdown(),
                            SizedBox(height: 24),
                            SwitchListTile(
                              title: Text(
                                'Auto Assign Orders',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: DriverColors.textPrimary,
                                ),
                              ),
                              value: _autoAssignOrders,
                              onChanged:
                                  (v) => setState(() => _autoAssignOrders = v),
                              activeColor: DriverColors.primary,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ]),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _driversController.isLoading.value
                                      ? null
                                      : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DriverColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Obx(
                                () =>
                                    _driversController.isLoading.value
                                        ? CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : Text(
                                          'Add Driver',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => _driversController.controller.cancelAddDriver(),
          icon: Icon(Icons.arrow_back, color: DriverColors.textSecondary),
        ),
        SizedBox(width: 16),
        Text(
          'Add New Driver',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: DriverColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DriverColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DriverColors.textPrimary,
            ),
          ),
          Divider(height: 32, color: DriverColors.border),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    bool isRequired = true,
    bool obscureText = false,
    bool? showVisibilityToggle,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DriverColors.textSecondary,
              ),
            ),
            if (isRequired)
              Text(' *', style: TextStyle(color: DriverColors.accentRed)),
          ],
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText && !_isPasswordVisible,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          style: TextStyle(fontSize: 14, color: DriverColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: DriverColors.textSecondary.withOpacity(0.5),
            ),
            prefixIcon: Icon(icon, size: 18, color: DriverColors.textSecondary),
            suffixIcon:
                showVisibilityToggle == true
                    ? IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Iconsax.eye_slash : Iconsax.eye,
                        size: 18,
                        color: DriverColors.textSecondary,
                      ),
                      onPressed:
                          () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                    )
                    : null,
            filled: true,
            fillColor: DriverColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: DriverColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: DriverColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: DriverColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: DriverColors.accentRed),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            counterText: '',
          ),
          validator: validator,
        ),
      ],
    );
  }

  // Specialized fields reusing the style
  Widget _buildPhoneField() {
    return _buildFormField(
      controller: _phoneController,
      label: 'Phone Number',
      hintText: '0300-1234567',
      icon: Iconsax.call,
      keyboardType: TextInputType.phone,
      maxLength: 13,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: (v) {
        if (v!.isEmpty) return 'Required';
        // logic for formatting check if needed, simplified for UI demo
        if (v.length < 11) return 'Invalid length';
        return null;
      },
    );
  }

  Widget _buildCNICField() {
    return _buildFormField(
      controller: _cnicController,
      label: 'CNIC',
      hintText: '35202-1234567-1',
      icon: Iconsax.card,
      keyboardType: TextInputType.number,
      maxLength: 15,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(13),
      ], // Formatter logic handles dashes visually? No, manual listener used
      validator: (v) {
        if (v!.isEmpty) return 'Required';
        if (!_cnicRegex.hasMatch(v)) return 'Invalid Format';
        return null;
      },
    );
  }

  Widget _buildZoneDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Service Zone',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DriverColors.textSecondary,
              ),
            ),
            Text(' *', style: TextStyle(color: DriverColors.accentRed)),
          ],
        ),
        SizedBox(height: 8),
        Obx(() {
          if (_zonesService.isLoading.value) {
            return Center(
              child: LinearProgressIndicator(color: DriverColors.primary),
            );
          }
          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: DriverColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        _selectedZone == null && _isFormSubmitted
                            ? DriverColors.accentRed
                            : DriverColors.border,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Zone>(
                    value: _selectedZone,
                    isExpanded: true,
                    hint: Text(
                      'Select Zone',
                      style: TextStyle(color: DriverColors.textSecondary),
                    ),
                    items:
                        _zonesService.zones.map((zone) {
                          return DropdownMenuItem<Zone>(
                            value: zone,
                            child: Text(
                              zone.zoneName,
                              style: TextStyle(color: DriverColors.textPrimary),
                            ),
                          );
                        }).toList(),
                    onChanged: (val) => setState(() => _selectedZone = val),
                  ),
                ),
              ),
              if (_selectedZone != null) ...[
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DriverColors.accentBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: DriverColors.accentBlue.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            size: 16,
                            color: DriverColors.accentBlue,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Zone Details',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: DriverColors.accentBlue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      if (_selectedZone!.description.isNotEmpty) ...[
                        Text(
                          _selectedZone!.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: DriverColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Icon(
                            Iconsax.ruler,
                            size: 14,
                            color: DriverColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Radius: ${_selectedZone!.radiusKm} km',
                            style: TextStyle(
                              fontSize: 12,
                              color: DriverColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedZone!.includedAreas.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          'Areas: ${_selectedZone!.includedAreas.join(", ")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: DriverColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }
}
