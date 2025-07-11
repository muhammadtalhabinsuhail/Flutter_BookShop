import 'package:flutter/material.dart';
import 'package:project/screen/customers/CustomerProfileUpdate/profile_image_picker.dart';
import 'package:project/screen/customers/CustomerProfileUpdate/profile_update_controller.dart';
import 'package:project/screen/customers/animated_app_bar.dart';
import '../../Admin/AdminDashboard/AdminDashboardView.dart';

import '../Cart/cart_screen.dart';
import '../Home/home_view.dart';
import '../Wishlist/wishlist_screen.dart';
import '../base_customer_screen.dart';
import 'app_logo_header.dart';
import 'custom_input_field.dart';

class CustomerProfileUpdateScreen extends StatefulWidget {
  const CustomerProfileUpdateScreen({super.key});

  @override
  State<CustomerProfileUpdateScreen> createState() => _CustomerProfileUpdateScreenState();
}

class _CustomerProfileUpdateScreenState extends State<CustomerProfileUpdateScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late ProfileUpdateController controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = ProfileUpdateController(
      usernameController: _usernameController,
      emailController: _emailController,
      formKey: _formKey,
      context: context,
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    await controller.loadUserData();
    setState(() {
      _isLoading = false;
    });
  }
  int _cartItemsCount = 3;

  int _selectedIndex = 4;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AnimatedAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),


                      // Title
                      const Text(
                        'Update your profile',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        'Keep your information up to date',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Profile Image Picker
                      ProfileImagePicker(
                        initialImageBase64: controller.profileImageBase64,
                        onImageSelected: (base64Image) {
                          controller.setProfileImage(base64Image);
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      Center(
                        child: Text(
                          'Tap to change profile picture',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Username Field
                      CustomInputField(
                        label: 'Username',
                        controller: _usernameController,
                        hintText: 'Enter your username',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      CustomInputField(
                        label: 'Email',
                        controller: _emailController,
                        hintText: 'Enter your email address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return controller.textBoxValidator(value, fieldName: 'Email');
                          }
                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(value)) {
                            return "Email format is not valid";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                                  await controller.updateProfile();
                                  setState(() {});
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            disabledBackgroundColor: Colors.grey[400],
                          ),
                          child: controller.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Update Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Cancel Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
        bottomNavigationBar: EnhancedBottomNavigation(currentIndex: 5,)
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}