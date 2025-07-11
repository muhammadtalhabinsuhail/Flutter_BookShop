import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user from preferences
  Future<String?> getCurrentUserEmail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print(prefs.getString('email'));
      return prefs.getString('email');
    } catch (e) {
      print('❌ Error getting current user email: $e');
      return null;
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('User')
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromSnapshot(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user by email: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    String? email = await getCurrentUserEmail();
    return email != null && email.isNotEmpty;
  }

  // Logout user
  Future<void> logoutUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Error logging out user: $e');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      String? email = await getCurrentUserEmail();
      if (email != null) {
        return await getUserByEmail(email);
      }
      return null;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }
}