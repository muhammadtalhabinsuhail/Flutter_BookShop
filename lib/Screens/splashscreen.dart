//
// import 'package:flutter/material.dart';
// import 'dart:async';
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   void initState() {
//     super.initState();
//     Timer(Duration(seconds: 3), () {
//       Navigator.pushReplacementNamed(context, "/products");
//       // Navigator.pushReplacementNamed(context, "/products");
//       // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Products()));
//       Navigator.pushNamed(context, "/products");
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // splash background colorMore actions
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.local_mall_outlined, size: 300, color: Colors.blue),
//
//
//               SizedBox(height: 20),
//               Text(
//                 'Ecommerce Project',
//                 style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.yellow
//                 ),
//               ),
//
//
//             ],
//           ),
//         ),
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
//
//
//
//
//       ),
//
//
//
//
//
//
//
//
//     );
//   }
// }
//
//
//
//
//
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, "/products");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(), // Push content to center
                      Icon(Icons.local_mall_outlined, size: 200, color: Colors.blue),
                      SizedBox(height: 20),
                      Text(
                        'Ecommerce Project',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                      Spacer(), // Push footer to bottom

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(

                          children: [
                            Text(
                              '© 2025 YourBrand. All rights reserved.',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: Text("Privacy Policy"),
                                ),
                                Text("|"),
                                TextButton(
                                  onPressed: () {},
                                  child: Text("Terms"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
