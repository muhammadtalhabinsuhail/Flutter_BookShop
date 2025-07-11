import 'package:flutter/material.dart';
import 'package:project/screen/customers/Home/home_view.dart';
import 'package:project/screen/customers/Login/LoginScreen.dart';
import 'package:project/screen/customers/SignUp/SignUpScreen.dart';

// import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [



                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 50,
                      decoration:  const BoxDecoration(
                        image: DecorationImage(
                          image:AssetImage(
                              "logo.png"

                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'READIUM',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(0),
                  ),
                    child: Center(
                    child:
                    Image(image: AssetImage('Splash.jpg'), height: 400,width: double.infinity,),
        
                  ),
                ),
                const SizedBox(height: 24),



              const SizedBox(height: 24),

                // Buttons Section
                Column(
                  children: [
                    // Create Account Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: const Text(
                          'Create your Account, Now!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.grey, width: 1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: const Text(
                          'Sign in to your account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // See Books Button (Additional)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate to books
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  Home(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.grey, width: 1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: const Text(
                          'See our collections',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

              ],
            ),
          ),
        ),
      ),
    );
  }
}