import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/Screens/Login.dart';
import 'package:project/Screens/SignUp.dart';
import 'package:project/Screens/ApiProduct.dart';
import 'package:project/Screens/UserList.dart';
import 'package:project/Screens/splashscreen.dart';
import 'Screens/EmailSender.dart';
import 'firebase_options.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    DevicePreview(
      enabled: true,
      tools: const [
        ...DevicePreview.defaultTools,
        // CustomPlugin(),
      ],
      builder: (context) =>  MyApp(),
    ),
  );


}











class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,

      //IDHER HAMARA KAAAM

      routes: {
        "/signup": (context) => SignUp(),
      },

      home:  Login(),

    );
  }
}






