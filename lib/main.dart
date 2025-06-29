import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/Screens/Admin/UsersList/customer_lists_screen.dart';
import 'package:project/Screens/Login.dart';
import 'package:project/Screens/SignUp.dart';
import 'package:project/Screens/ApiProduct.dart';
import 'package:project/Screens/UserList.dart';
import 'package:project/Screens/splashscreen.dart';
import 'package:provider/provider.dart';

import 'Screens/Admin/AddProduct/AddProductView.dart';
import 'Screens/Admin/AdminDashboard/AdminDashboardView.dart';
import 'Screens/Admin/Catagory/AddCatagory.dart';
import 'Screens/Admin/Catagory/category_management_screen.dart';
import 'Screens/Admin/UsersList/user_info_screen.dart';
import 'Screens/Customer/Cart/CartScreen.dart';
import 'Screens/Customer/CustomerProfileUpdate/customer_profile_update_screen.dart';
import 'Screens/EmailSender.dart';
import 'Screens/Customer/Login/LoginScreen.dart';
import 'Screens/Customer/Home/HomeView.dart';
import 'Screens/Customer/SignUp/SignUpScreen.dart';

import 'firebase_options.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:project/Screens/Customer/Home/HomeView.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryController()),
        // Add more providers here if needed
      ],
      child: DevicePreview(
        enabled: true,
        tools: const [
          ...DevicePreview.defaultTools,
        ],
        builder: (context) => MyApp(),
      ),
    ),
  );
}





class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Inter',
      ),
       home:AdminDashboard(selectedIndex: 0,),// CustomerProfileUpdateScreen(),// AdminDashboard(selectedIndex: 0,),
      debugShowCheckedModeBanner: false,
    );
  }
}