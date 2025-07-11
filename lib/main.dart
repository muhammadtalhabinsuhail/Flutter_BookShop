import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/screen/Admin/AdminDashboard/AdminDashboardView.dart';
import 'package:project/screen/Admin/AllOrders/all_orders_screen.dart';
import 'package:project/screen/Admin/Catagory/AddCatagory.dart';
import 'package:project/screen/Admin/Catagory/category_management_screen.dart';
import 'package:project/screen/Admin/Customers/admin_panel_screen.dart';
import 'package:project/screen/Admin/WishList/wishlist_management_screen.dart';
import 'package:project/screen/customers/Home/home_view.dart';
import 'package:project/screen/customers/Login/LoginScreen.dart';
import 'package:project/screen/customers/OrdersTracking/my_orders_screen.dart';
import 'package:project/screen/splashscreen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';



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

      routes: {
        '/login': (context) => LoginScreen(),
        '/my-orders':(context) => MyOrdersScreen(),
         '/admin' : (context) => AdminDashboard(selectedIndex: 0)
      },
      title: 'Book App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Inter',
      ),
       home:SplashScreen(),//Home(),//WishlistManagementScreen(selectedIndex: 4),// CustomerProfileUpdateScreen(),// AdminDashboard(selectedIndex: 0,),
      debugShowCheckedModeBanner: false,

    );
  }
}