// // import 'dart:convert';
// //
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'dart:convert';
// // import 'dart:typed_data';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:image_preview/preview.dart';
// // import 'package:image_preview/preview_data.dart';
// // import 'package:project/Screens/AppDrawer.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// //
// //
// //
// //
// // class SignUpController {
// //   final TextEditingController usernameController;
// //   final TextEditingController emailController;
// //   final TextEditingController passwordController;
// //   final TextEditingController confirmPasswordController;
// //   final GlobalKey<FormState> formKey;
// //   final BuildContext context;
// //
// //   SignUpController({
// //     required this.usernameController,
// //     required this.emailController,
// //     required this.passwordController,
// //     required this.confirmPasswordController,
// //     required this.formKey,
// //     required this.context,
// //   });
// //
// //
// //   // 🟢 Global Validator Function
// //   String? TextBoxValidator(String? value, {String fieldName = "field"}) {
// //     if (value == null || value.trim().isEmpty) {
// //       return 'Please Enter Your $fieldName';
// //     }
// //     return null;
// //   }
// //
// //
// //
// //
// //
// //
// //   //IMAGE PICKER FROM MOBILE GALLERY
// //   String imgUrl="";
// //   final ImagePicker picker = ImagePicker();
// //   getImage() async {
// //     // final ImagePicker picker = ImagePicker();
// //     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
// //
// //     final Uint8List byteImage = await image!.readAsBytes();
// //     //image--> [12,121,25454,2187,88785,854577,4,4,878,45,4,.....]
// //     print(byteImage);
// //     //base 64 algorithm
// //     final String base64img = base64Encode(byteImage);
// //     print(base64img);
// //     setState(() {
// //       imgUrl = base64img;
// //     });
// //   }
// //
// //
// //
// //
// // // YA LINE FIREBASE MA COLLECTION BANA DA GI
// //   CollectionReference Users = FirebaseFirestore.instance.collection('User');
// //
// //   dynamic globallyUID;
// //   void RegisterUser() async{
// //     if (formKey.currentState!.validate()) {
// //
// //       try {
// //         final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
// //           email: emailController.text,
// //           password: passwordController.text,
// //         );
// //
// //         print("sign up success");
// //         print(credential.user!.uid);
// //
// //         globallyUID = credential.user!.uid;
// //
// //         // adding user details in user collection too
// //         Users.doc(credential.user!.uid).set({     //credential.user!.uid  ya authentication ki id ko user id ma rkha ga
// //           'username':usernameController.text,
// //           'Profile': imgUrl,
// //           'role':"Customer"
// //
// //         }).then((value) => {
// //         emailController.clear(),
// //         passwordController.clear(),
// //         usernameController.clear(),
// //
// //
// //         ScaffoldMessenger.of(context).showSnackBar(
// //
// //
// //         const SnackBar(
// //         content: Text('Account created successfully!'),
// //         backgroundColor: Colors.black,
// //         ),
// //         ),
// //
// //         // Navigate to login screen
// //         Future.delayed(const Duration(seconds: 1), () {
// //         Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(
// //         builder: (context) => const LoginScreen(),
// //         ),
// //         );
// //         }).catchError((error) => {
// //         const SnackBar(
// //         content: Text('Account created successfully!'),
// //         backgroundColor: Colors.black,
// //         ),
// //         });
// //
// //
// //             UserSignIn();
// //
// //         on FirebaseAuthException catch (e) {
// //         if (e.code == 'weak-password') {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(content: Text("The password provided is too weak."),));
// //         } else if (e.code == 'email-already-in-use') {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(content: Text("This email account is already exist."),));
// //         }
// //       } catch (e) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text("Something went wrong."),));
// //       }
// //
// //     else {
// //       print("Please insert valid details");
// //     }
// //
// //
// //     void UserSignIn() async {
// //       final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
// //         email: emailController.text,
// //         password: passwordController.text,
// //       );
// //
// //
// //       final SharedPreferences prefs = await SharedPreferences.getInstance();
// //       prefs.setBool("isLoggedIn", true);
// //
// //       prefs.setString("role", "Customer");
// //       prefs.setString("username", "$usernameController");
// //       prefs.setString("id", globallyUID);
// //       prefs.setString("email", "$emailController");
// //
// //
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(
// //             "Also Signed in as ${emailController.text}",
// //             style: TextStyle(color: Colors.white),
// //           ),
// //           backgroundColor: const Color.fromARGB(255, 220, 0, 255),
// //         ),
// //       );
// //     }
// //   }
// //
// //
// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:project/Screens/Customer/Home/HomeView.dart';
// import 'package:project/Screens/Customer/Login/LoginScreen.dart'; // <-- Make sure this exists
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../Login/LoginScreen.dart';
//
// class SignUpController {
//   final TextEditingController usernameController;
//   final TextEditingController emailController;
//   final TextEditingController passwordController;
//   final TextEditingController confirmPasswordController;
//   final GlobalKey<FormState> formKey;
//   final BuildContext context;
//
//   SignUpController({
//     required this.usernameController,
//     required this.emailController,
//     required this.passwordController,
//     required this.confirmPasswordController,
//     required this.formKey,
//     required this.context,
//   });
//
//   // 🔵 Firebase Collection
//   final CollectionReference Users = FirebaseFirestore.instance.collection('User');
//
//
//   // 🔵 Text Field Validator
//   String? textBoxValidator(String? value, {String fieldName = "field"}) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter your $fieldName';
//     }
//     return null;
//   }
//
//   // 🔵 Global UID
//   dynamic globallyUID;
//
//   // 🔵 Register User Method
//   Future<void> registerUser() async {
//     if (formKey.currentState!.validate()) {
//       try {
//         final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: emailController.text.trim(),
//           password: passwordController.text.trim(),
//         );
//
//         print("Sign up success");
//         globallyUID = credential.user!.uid;
//
//         await Users.doc(globallyUID).set({
//           'UserName': usernameController.text.trim(),
//           'Email':emailController.text.trim(),
//           'Password':passwordController.text.trim(),
//           'Role': "Customer",
//
//
//
//
//
//         });
//
//
//
//         // Show success
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Account created successfully!'),
//             backgroundColor: Colors.black,
//           ),
//         );
//
//         // Auto sign in
//          bool ans = await userSignIn();
//
// if(ans == true) {
//   // Clear fields
//   usernameController.clear();
//   emailController.clear();
//   passwordController.clear();
//   confirmPasswordController.clear();
//
//
//   // Navigate to login screen
//   Future.delayed(const Duration(seconds: 1), () {
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const Home()),
//     );
//
//
//
//
//   });
// }
//
//
//       } on FirebaseAuthException catch (e) {
//         if (e.code == 'weak-password') {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("The password provided is too weak."),backgroundColor: Colors.red,),
//           );
//         } else if (e.code == 'email-already-in-use') {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("This email account already exists."),backgroundColor: Colors.red,),
//           );
//         }
//       } catch (e) {
//         print("Error: $e");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Something went wrong."),backgroundColor: Colors.red,),
//         );
//       }
//     } else {
//       print("Please insert valid details");
//     }
//   }
//
//
//   Future<bool> userSignIn() async {
//     String email = emailController.text.trim();
//     String password = passwordController.text.trim();
//
//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Email and password cannot be empty"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return false;
//     }
//
//     // Simple email validation regex
//     bool isValidEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
//
//     if (!isValidEmail) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please enter a valid email address"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return false;
//     }
//
//     try {
//       final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setBool("isLoggedIn", true);
//       prefs.setString("role", "Customer");
//       prefs.setString("username", usernameController.text.trim());
//       prefs.setString("id", globallyUID); // Make sure globallyUID is initialized
//       prefs.setString("email", email);
//
//
//
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "Also signed in as $email",
//             style: const TextStyle(color: Colors.white),
//           ),
//           backgroundColor: const Color.fromARGB(255, 220, 0, 255),
//         ),
//       );
//       return true;
//     } catch (e) {
//       print("Auto login failed: $e");
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Login failed: ${e.toString()}"),
//           backgroundColor: Colors.red,
//         ),
//       );
//
//       return false;
//     }
//   }
//
//
//
//
//
//
//
//
//
//
//
// }
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/Screens/Customer/Home/HomeView.dart';
import 'package:project/Screens/Customer/Login/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/Users.dart';

class SignUpController {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> formKey;
  final BuildContext context;

  SignUpController({
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formKey,
    required this.context,
  });

  // 🔵 Text Field Validator
  String? textBoxValidator(String? value, {String fieldName = "field"}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  // 🔵 Global UID
  dynamic globallyUID;

  // 🔵 Register User Method - Now using UsersModel
  Future<void> registerUser() async {
    if (formKey.currentState!.validate()) {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        print("Sign up success");
        globallyUID = credential.user!.uid;

        // Create user model instance
        UsersModel newUser = UsersModel(
          userName: usernameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          role: "Customer",
        );

        // Use the model's repository to create user
        bool userCreated = await UsersRepository.createUser(newUser, globallyUID);

        if (userCreated) {
          // Show success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.black,
            ),
          );

          // Auto sign in
          bool ans = await userSignIn();

          if (ans == true) {
            // Clear fields
            usernameController.clear();
            emailController.clear();
            passwordController.clear();
            confirmPasswordController.clear();

            // Navigate to home screen
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to save user data."),
              backgroundColor: Colors.red,
            ),
          );
        }

      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("The password provided is too weak."),
              backgroundColor: Colors.red,
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This email account already exists."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print("Please insert valid details");
    }
  }

  Future<bool> userSignIn() async {
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
    bool isValidEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);

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
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("isLoggedIn", true);
      prefs.setString("role", "Customer");
      prefs.setString("username", usernameController.text.trim());
      prefs.setString("id", globallyUID);
      prefs.setString("email", email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Also signed in as $email",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 220, 0, 255),
        ),
      );
      return true;
    } catch (e) {
      print("Auto login failed: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }
}