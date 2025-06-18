import 'package:flutter/material.dart';
import 'package:project/Screens/AppDrawer.dart';

class Apiproduct extends StatefulWidget {
  const Apiproduct({super.key});

  @override
  State<Apiproduct> createState() => _ApiproductState();

}




List<Map<String, dynamic>> products = [
  {
    "name": "Honda Civic",
    "imageUrl": "https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/1.webp",
    "price": 3000000
  },
  {
    "name": "Toyota Corolla",
    "imageUrl": "https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp",
    "price": 2800000
  },
  {
    "name": "Suzuki Swift",
    "imageUrl": "https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/thumbnail.webp",
    "price": 2200000
  }
];




class _ApiproductState extends State<Apiproduct> {

  @override

  Widget build(BuildContext context) {





var appBar = AppBar(
  backgroundColor: Colors.blueAccent,
  foregroundColor: Colors.white,
  title: Text("Our Products"),
  centerTitle: true,
);



var body=Padding(
  padding: EdgeInsets.symmetric(horizontal:0,vertical:10),
  child: SingleChildScrollView(
    padding: EdgeInsets.all(8.0),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal, // <-- key line
      // padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
          products.map((prod) {
            return Container(
              width: 200,
              margin: EdgeInsets.all(10),
              child: Card(
                child: Column(
                  children: [
                    Image.network(prod['imageUrl'], height: 120, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(prod['name']),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        
        
        
      ),
    ),
  ),
);

    return  Scaffold(
        appBar:appBar,
         drawer: Appdrawer(),
         body: body,
    );
  }
}
