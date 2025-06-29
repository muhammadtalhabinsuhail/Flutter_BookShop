import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/Screens/AppDrawer.dart';
import 'package:project/Screens/EditUser.dart';

class Userlist extends StatefulWidget {
  const Userlist({super.key});

  @override
  State<Userlist> createState() => _UserlistState();
}

class _UserlistState extends State<Userlist> {

  void DeletingUser(String userId
) async {
    try {
      await FirebaseFirestore.instance.collection('User').doc(userId
).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User Deleted Successfully!')),
      );
    }
    catch(ex){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong!',style: TextStyle(color: Colors.red),)),
      );
    }

  }







  @override
  Widget build(BuildContext context) {


    var appBar = AppBar(
      title: Text('Home Shop Members'),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      centerTitle: true,
    );





    var body = StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('User').snapshots(), // 🔸 Use the variable here
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {

              var data = users[index].data() as Map<String, dynamic>;
              String userId
              = users[index].id;


              return ListTile(
                leading: Icon(Icons.person),
                title: Text('Name: ${data['UserName'] ?? 'No Name'}'),
                subtitle: Text('${data['Email'] ?? 'No Name'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        Navigator.push(context,MaterialPageRoute(builder: (context) => Edituser(UserId: userId)));
                      },
                      child: Text("Edit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => DeletingUser(userId),
                      child: Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),

              );


            },


          );
        }
    );
    return  Scaffold(
      appBar: appBar,
      drawer: Appdrawer(),
      body: body
    );
  }
}



