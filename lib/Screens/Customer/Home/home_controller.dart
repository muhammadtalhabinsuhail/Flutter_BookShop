import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Models/ProductModel.dart';

class HomeController {
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

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Books').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching product by ID: $e');
      return null;
    }
  }
}