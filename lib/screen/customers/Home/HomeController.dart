import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/ProductModel.dart';


class Homecontroller {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProductModel>> getAllProducts() async {


    try {
      QuerySnapshot snapshot = await _firestore.collection('Books').get();
      List<ProductModel> data = snapshot.docs.map((doc) {
        return ProductModel.fromSnapshot(doc);
      }).toList();

      print("✅ PRODUCTS FETCHED: ${data.length}");
      for (var p in data) {
        print("Product: ${p.name} | Price: ${p.price} | Image: ${p.imgurl}");
      }

      return data;
    } catch (e) {
      print('❌ Error fetching products: $e');
      return [];
    }






  }
}
