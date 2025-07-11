import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/screen/model/Users.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileUpdateController {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final GlobalKey<FormState> formKey;
  final BuildContext context;

  ProfileUpdateController({
    required this.usernameController,
    required this.emailController,
    required this.formKey,
    required this.context,
  });

  String? _profileImageBase64;
  bool _isLoading = false;

  String? get profileImageBase64 => _profileImageBase64;
  bool get isLoading => _isLoading;

  void setProfileImage(String base64Image) {
    _profileImageBase64 = base64Image;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  // Text Field Validator
  String? textBoxValidator(String? value, {String fieldName = "field"}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  // Load current user data
  Future<void> loadUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        UsersModel? user = await UsersRepository.getUserById(currentUser.uid);
        if (user != null) {
          usernameController.text = user.userName;
          print("This will be user name:"+user.userName);
          emailController.text = user.email;
          _profileImageBase64 = user.profile;
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load user data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Update user profile
  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setLoading(true);

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Update user data in Firestore
      Map<String, dynamic> updateData = {
        'UserName': usernameController.text.trim(),
        'Email': emailController.text.trim(),
      };

      if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
        updateData['Profile'] = _profileImageBase64;
      }

      bool success = await UsersRepository.updateUserFields(
        currentUser.uid,
        updateData,
      );

      if (success) {
        // Update email in Firebase Auth if changed
        if (currentUser.email != emailController.text.trim()) {
          await currentUser.updateEmail(emailController.text.trim());
        }

        // Update SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("username", usernameController.text.trim());
        prefs.setString("email", emailController.text.trim());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.black,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update profile');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to update profile';
      if (e.code == 'requires-recent-login') {
        errorMessage = 'Please log in again to update your email';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use by another account';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setLoading(false);
    }
  }
}