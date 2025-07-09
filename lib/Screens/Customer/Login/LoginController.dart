import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/Screens/Customer/Home/HomeView.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController{

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


signInWithGoogle(context) async {
  GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
  print(userCredential.user?.displayName);
  if (userCredential.user != null) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }
}
