import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'AppDrawer.dart';

class Edituser extends StatefulWidget {
  final String UserId;
  const Edituser({Key?key, required this.UserId}):super(key:key);

  @override
  State<Edituser> createState() => _EdituserState();
}

class _EdituserState extends State<Edituser> {


  final _formKey = GlobalKey<FormState>(); // Form ka key (for validation)
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;






  //FETCHING DATA OF THAT USER ID
  Future<void> UserFetch() async {
    try{
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("User").doc(widget.UserId).get();
      if(doc.exists && doc != ""){
        var user = doc.data();

        // ab dot map use kr ka controllers ma data rkhwa do phir wo khud text box ma rakh den ga
        //Map<String, dynamic>   idher String datatype key ka lia hai aur dynamic (yani int bool and all...) value ka lia
        Map<String,dynamic> UserInMap = user as Map<String,dynamic>;

        // ab controllers ma data rkhwadoo
        _nameController.text = UserInMap['UserName'] ?? "";
        _emailController.text = UserInMap["Email"]??"";
        _passwordController.text = UserInMap["Password"]??"";



      }

      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not Found."),));
      }

    }
    catch (ex){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong.User was not get"),));

    }
  }



  //USER FETCH WALA FUNCTION AUTOMATICALLY PAGE RENDER HONA PR CHALNA CHAHIYA NA IS LIA DEKO

  @override
  void initState() {
    super.initState();
    UserFetch(); // page load hotay hi call hoga
  }



// YA LINE FIREBASE MA COLLECTION BANA DA GI
  CollectionReference Users = FirebaseFirestore.instance.collection('User');

  dynamic globallyUID;
  void RegisterUser() async{
    if (_formKey.currentState!.validate()) {

      try {




        DocumentSnapshot doc = await FirebaseFirestore.instance.collection("User").doc(widget.UserId).get();



        // adding user details in user collection too
        Users.doc(widget.UserId).set({     //credential.user!.uid  ya authentication ki id ko user id ma rkha ga
          'UserName':_nameController.text,
          'Email':_emailController.text,
          'Password':_passwordController.text,
          'Profile': imgUrl,
          'role':"Customer"

        }).then((value) => {
          _emailController.clear(),
          _passwordController.clear(),
          _nameController.clear(),



          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
              Text("Edited Successfully..✔",style: TextStyle(color: Colors.white),), backgroundColor: Colors.deepPurple) ,)

        }).catchError((error) => {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register user"),))
        });



      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The password provided is too weak."),));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("This email account is already exist."),));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong.User was not registered"),));
      }

    } else {
      print("Please insert valid details");
    }
  }










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



    var body = Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 0),

        child: Center(
          child: ListView(
            children: [


              Image(image: AssetImage('SignUp.png'),height: 270,),


              Text("Edit User",
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
                        child: Text('Edit the user'),
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
