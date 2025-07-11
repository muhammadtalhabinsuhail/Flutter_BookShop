import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Cart/cart_screen.dart';

class LoginController{






  Future<void> ReversecheckoutCartItems(BuildContext context) async {
    try {
      // Get current user email from preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');
      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Get user document by email
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('User')
          .where('Email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
        return;
      }

      String userId = userQuery.docs.first.id;

      // delete checkout items a/c to userid and orderplaced is false
      // delete checkout items a/c to userid and orderplaced is false
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Checkout')
          .where('userId', isEqualTo: userId)
          .where('orderStatus', isEqualTo: "Pending")
          .get();
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Update all cart items for this user to isCheckedOut: true
      QuerySnapshot cartQuery = await FirebaseFirestore.instance
          .collection('Cart')
          .where('UserId', isEqualTo: userId)
          .where('isCheckedOut', isEqualTo: true)
          .where('OrderPlaced', isEqualTo: false)
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (QueryDocumentSnapshot doc in cartQuery.docs) {
        batch.update(doc.reference, {'isCheckedOut': false});
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must place order within 3 minutes after checking out!'),
          backgroundColor: Colors.black,
        ),
      );

      // Navigate to checkout page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }







  Future<bool> userSignIn(final _loginkey, final emailController,final passwordController,BuildContext context) async {

    if (_loginkey.currentState!.validate()) {

      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email and password cannot be empty"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Simple email validation regex
      bool isValidEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(
          email);

      if (!isValidEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid email address"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email,
          password: password,
        );


        var users = FirebaseFirestore.instance.collection("User");
        String uid = credential.user!.uid;
        var userData = await users.doc(uid).get();
        var userDetails = userData.data();
        print(userDetails);


        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setBool("isLoggedIn", true);
        prefs.setString("role", userDetails!["Role"]);
        prefs.setString("username", userDetails!["UserName"]);
        prefs.setString("id", uid);
        prefs.setString("email", userDetails!["Email"]);

        print(userDetails!["UserName"]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Welcome! Signed in as $email",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        ReversecheckoutCartItems(context);

        return true;


      } catch (e) {
        print("Auto login failed: $e");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: Credentials Error! OR Account has been expired!"),
            backgroundColor: Colors.red,
          ),
        );

        return false;
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Enter Valid Credentials"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }


  String? textBoxValidator(String? value, {String fieldName = "field"}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }












}
