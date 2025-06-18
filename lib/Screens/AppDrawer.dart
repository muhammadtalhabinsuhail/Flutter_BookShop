import 'package:flutter/material.dart';
import 'package:project/Screens/ApiProduct.dart';
import 'package:project/Screens/Login.dart';
import 'package:project/Screens/SignUp.dart';
import 'package:project/Screens/UserList.dart';

class Appdrawer extends StatefulWidget {
  const Appdrawer({super.key});

  @override
  State<Appdrawer> createState() => _AppdrawerState();
}

class _AppdrawerState extends State<Appdrawer> {
  @override
  Widget build(BuildContext context) {

    //DRAWER CLASS
    return Drawer(

      // LISTVIEW
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          //DRAWER HEADER
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),

            child: Text(
              'Drawer Header',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),


          //LIST TILE
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Api Products'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder:  (context) => Apiproduct()));},
          ),


          ListTile(
            leading: Icon(Icons.home),
            title: Text('Sign Up'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder:  (context) => SignUp()));},
          ),



          ListTile(
            leading: Icon(Icons.home),
            title: Text('User Lists'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder:  (context) => Userlist()));},
          ),



          ListTile(
            leading: Icon(Icons.home),
            title: Text('Login'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder:  (context) => Login()));},
          ),




        ],
      ),

    );
  }
}
