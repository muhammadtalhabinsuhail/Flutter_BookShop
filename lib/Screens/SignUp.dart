import 'dart:convert';
import 'dart:typed_data';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_preview/preview.dart';
import 'package:image_preview/preview_data.dart';
import 'package:project/Screens/AppDrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}


// ______________________________________________________________________________________________________

class _SignUpState extends State<SignUp> {



  final _formKey = GlobalKey<FormState>(); // Form ka key (for validation)
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;















  // 🟢 Global Validator Function
  String? TextBoxValidator(String? value, {String fieldName = "field"}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please Enter Your $fieldName';
    }
    return null;
  }






   //IMAGE PICKER FROM MOBILE GALLERY
    String imgUrl="";
    final ImagePicker picker = ImagePicker();
    getImage() async {
    // final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    final Uint8List byteImage = await image!.readAsBytes();
    //image--> [12,121,25454,2187,88785,854577,4,4,878,45,4,.....]
    print(byteImage);
    //base 64 algorithm
    final String base64img = base64Encode(byteImage);
    print(base64img);
    setState(() {
      imgUrl = base64img;
    });
   }




// YA LINE FIREBASE MA COLLECTION BANA DA GI
  CollectionReference Users = FirebaseFirestore.instance.collection('User');

  dynamic globallyUID;
  void RegisterUser() async{
    if (_formKey.currentState!.validate()) {

      try {


        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        print("sign up success");
        print(credential.user!.uid);

        globallyUID = credential.user!.uid;

        // adding user details in user collection too
        Users.doc(credential.user!.uid).set({     //credential.user!.uid  ya authentication ki id ko user id ma rkha ga
          'username':_nameController.text,
          'Profile': imgUrl,
          'role':"Customer"

        }).then((value) => {
          _emailController.clear(),
          _passwordController.clear(),
          _nameController.clear(),


          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
            Text("Registered Successfully..✔",style: TextStyle(color: Colors.white),), backgroundColor: Colors.deepPurple,)) ,

        }).catchError((error) => {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register user"),))
        });


        UserSignIn();

      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The password provided is too weak."),));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("This email account is already exist."),));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong."),));
      }

    } else {
      print("Please insert valid details");
    }
  }




  void UserSignIn() async{
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );


    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLoggedIn", true);

    prefs.setString("role", "Customer");
    prefs.setString("username", "$_nameController");
    prefs.setString("id", globallyUID);
    prefs.setString("email", "$_emailController");



    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Also Signed in as ${_emailController.text}",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 220, 0, 255),
      ),
    );


  }


// ______________________________________________________________________________________________________

  @override
  Widget build(BuildContext context) {

    var appBar = AppBar(
      title: Text('Home Shop'),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      centerTitle: true,


      actions: [
        IconButton(

        onPressed: (){
          Navigator.pushNamed(context, "/signup");
        }
        , icon: Icon(Icons.add)

        )
      ],


    );

    // ______________________________________________________________________________________________________

    var body = Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 0),

        child: Center(
          child: ListView(
            children: [


              Image(image: AssetImage('SignUp.png'),height: 270,),


              Text("Sign Up",
                textAlign:TextAlign.center,
                style: TextStyle(fontSize: 35,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,),



              ),

              Text("Create your account, Now!",
                textAlign:TextAlign.center,
                ),
              SizedBox(height: 10),





              Form(
                key: _formKey, // Ye zaroori hai for validation
                child: Column(
                  children: [









                    TextFormField(
                      controller: _nameController,

                      decoration: InputDecoration(
                      labelText: 'UserName',
                      hintText: "Enter Your Name",
                      ),

                      validator: (value) {
                       return TextBoxValidator(value,fieldName: 'Name');  // ya custom mana funct banaya ha /controls
                      },

                    ),











                    SizedBox(height: 20),



                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,

                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: "Enter Your Email",

                      ),

                      validator: (value) {
                        if (value!.isEmpty) {
                          return TextBoxValidator(value,fieldName: 'Email');// ya custom mana funct banaya ha
                        }
                        if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value)) {
                          return ("Email format is not valid");
                        }
                        return null;


                      },

                    ),











                    SizedBox(height: 20),



              TextFormField(
                controller: _passwordController,
              decoration: InputDecoration(
              labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
                obscureText: _obscurePassword,




                      validator: (value) {


                        if (value!.isEmpty) {
                          return TextBoxValidator(value,fieldName: 'Password');  // ya custom mana funct banaya ha
                        }

                        if (!RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[`~!@#$%^&*()\-_=+\[{\]}\|;:,<.>/?])[A-Za-z\d`~!@#$%^&*()\-_=+\[{\]}\|;:,<.>/?]{8,}$'
                        ).hasMatch(value)) {
                          return ("Password must have at least one uppercase letter, one lowercase letter, one digit, one special character, and be at least 8 characters long");
                        }

                        return null;

                      },

                    ),


                    SizedBox(height: 20,),







                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,




                      validator: (value) {


                        if (value!.isEmpty) {
                          return TextBoxValidator(value,fieldName: 'Confirm Password');  // ya custom mana funct banaya ha
                        }
//KAAAM
                        if(value != _passwordController){
                          return TextBoxValidator(value,fieldName: 'Password is not matched or');
                        }

                        return null;

                      },

                    ),


                    SizedBox(height: 20,),












                    ElevatedButton(onPressed:(){
                      getImage();
                    }


                        , child: Text("Choose File")
                    ),



                    SizedBox(height: 30),

                    ElevatedButton(
                      child: Text('Sign Me Up'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple
                      ),
                       onPressed: RegisterUser    //RegisterUser   function name ha...

                    ),





                  ],
                ),
              ),



            ],
          ),
        ),



      ),
    );


    // ______________________________________________________________________________________________________

    return Scaffold(
      appBar: appBar,
      drawer: Appdrawer(),
      body: body,
    );
  }
}
