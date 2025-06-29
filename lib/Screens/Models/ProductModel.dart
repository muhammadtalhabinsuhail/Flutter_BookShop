// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ProductModel {
//   final String name;
//   final double price;
//   final String description;
//   final double? minprice;
//   final double? maxprice;
//   late String? categoryid;
//   final String imgurl;
//   late int quantity;
//   final isAvailable = 5;
//
//   // Constructor
//   ProductModel({
//     required this.name,
//     required this.price,
//     required this.description,
//     this.minprice,
//     this.maxprice,
//     this.categoryid,
//     required this.imgurl,
//      required this.quantity
//   });
//
//   // 🔄 toMap(): For CREATE and UPDATE (to send data to Firestore)
//   Map<String, dynamic> toMap() {
//     return {
//       'Title': name,
//       'Price': price,
//       'Description': description,
//       'MinPrice': minprice,
//       'MaxPrice': maxprice,
//       'CategoryId': categoryid,
//       'ImgUrl': imgurl,
//       'Quantity':quantity
//     };
//   }
//
//   // 🔁 fromMap(): For READ single object (e.g. from Firestore map)
//   factory ProductModel.fromMap(Map<String, dynamic> map) {
//     return ProductModel(
//       name: map['Title'] ?? '',
//       price: (map['Price'] ?? 0).toDouble(),
//       description: map['Description'] ?? '',
//       minprice: (map['MinPrice'] ?? 0).toDouble(),
//       maxprice: (map['MaxPrice'] ?? 0).toDouble(),
//       categoryid: map['CategoryId'],
//       imgurl: map['ImgUrl'] ?? '',
//       quantity: map["Quantity"]??0,
//     );
//   }
//
//   // 🔁 fromSnapshot(): For READ a document snapshot from Firestore
//   factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return ProductModel.fromMap(data);
//   }
//
//   // 📋 fromQuerySnapshot(): For READ multiple documents from a collection
//   static List<ProductModel> fromQuerySnapshot(QuerySnapshot snapshot) {
//     return snapshot.docs
//         .map((doc) => ProductModel.fromSnapshot(doc))
//         .toList();
//   }
//
//
// }
//
import 'dart:convert';
// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:typed_data'; // ✅

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductModel {
  final String? id; // Added for document ID
  final String name;
  final double price;
  final String description;
  final double? minprice;
  final double? maxprice;
  late String? categoryid;
  final String imgurl;
  late int quantity;
  final isAvailable = 5;
  final DateTime? createdAt; // Added for timestamp

  // Constructor
  ProductModel({
    this.id, // Added optional ID parameter
    required this.name,
    required this.price,
    required this.description,
    this.minprice,
    this.maxprice,
    this.categoryid,
    required this.imgurl,
    required this.quantity,
    this.createdAt, // Added optional createdAt parameter
  });

  // 🔄 toMap(): For CREATE and UPDATE (to send data to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'Title': name,
      'Price': price,
      'Description': description,
      'MinPrice': minprice,
      'MaxPrice': maxprice,
      'CategoryId': categoryid,
      'ImgUrl': imgurl,
      'Quantity': quantity,
      'CreatedAt': createdAt ?? FieldValue.serverTimestamp(), // Added timestamp
    };
  }

  // 🔁 fromMap(): For READ single object (e.g. from Firestore map)
  factory ProductModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return ProductModel(
      id: documentId, // Added document ID
      name: map['Title'] ?? '',
      price: (map['Price'] ?? 0).toDouble(),
      description: map['Description'] ?? '',
      minprice: map['MinPrice'] != null ? (map['MinPrice']).toDouble() : null,
      maxprice: map['MaxPrice'] != null ? (map['MaxPrice']).toDouble() : null,
      categoryid: map['CategoryId'],
      imgurl: map['ImgUrl'] ?? '',
      quantity: map["Quantity"] ?? 0,
      createdAt: map['CreatedAt']?.toDate(), // Added timestamp parsing
    );
  }

  // 🔁 fromSnapshot(): For READ a document snapshot from Firestore
  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap(data, doc.id); // Pass document ID
  }

  // 📋 fromQuerySnapshot(): For READ multiple documents from a collection
  static List<ProductModel> fromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => ProductModel.fromSnapshot(doc))
        .toList();
  }

  // Added: Copy with method for easy updates
  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    double? minprice,
    double? maxprice,
    String? categoryid,
    String? imgurl,
    int? quantity,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      minprice: minprice ?? this.minprice,
      maxprice: maxprice ?? this.maxprice,
      categoryid: categoryid ?? this.categoryid,
      imgurl: imgurl ?? this.imgurl,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Updated PurchaseHistoryModel to work with your ProductModel
class PurchaseHistoryModel {
  final String? id;
  final DocumentReference userId  ;
  final DocumentReference productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final double totalPrice;
  final DateTime purchaseDate;
  final String? comment;

  PurchaseHistoryModel({
    this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.purchaseDate,
    this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'BookId': productId,
      'productname': productName,
      'productImage': productImage,
      'Quantity': quantity,
      'price': price,
      'TotalPrice': totalPrice,
      'PurchaseDate': purchaseDate,
      'comment': comment,
    };
  }


  factory PurchaseHistoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PurchaseHistoryModel(
      id: documentId,
      userId: map['UserId'] as DocumentReference,
      productId: map['BookId'] as DocumentReference,
      productName: map['productname'] ?? '',
      productImage: map['productImage'] ?? '',
      quantity: map['Quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      purchaseDate: map['PurchaseDate']?.toDate() ?? DateTime.now(),
      comment: map['comment'],
    );
  }

  // Create PurchaseHistoryModel from your ProductModel
  factory PurchaseHistoryModel.fromProductModel({
    required ProductModel product,
    required DocumentReference userId,
    required DocumentReference productRef, // <-- add this
    required int quantity,
    required DateTime purchaseDate,
    String? comment,
  }) {
    return PurchaseHistoryModel(
      userId: userId,
      productId: productRef,
      productName: product.name,
      productImage: product.imgurl,
      quantity: quantity,
      price: product.price,
      totalPrice: product.price * quantity,
      purchaseDate: purchaseDate,
      comment: comment,
    );
  }


  Future<Uint8List?> fetchProductImage(PurchaseHistoryModel purchase) async {
    try {
      // Step 1: Get productId from reference
      String productId = purchase.productId.id;

      // Step 2: Fetch the document from 'Books' collection
      DocumentSnapshot productSnap = await FirebaseFirestore.instance
          .collection('Books')
          .doc(productId)
          .get();

      if (productSnap.exists) {
        String base64Image = productSnap['productImage']; // or correct field name

        // Now you can decode and use the image
        Uint8List? imageBytes = safeBase64Decode(base64Image);
        if (imageBytes != null) {
          // Show this in your widget, for example:
          return imageBytes;
        }
      }
      else{
        return null;
      }
    } catch (e) {
   return null;
    }
  }

// Safe decode function
  Uint8List? safeBase64Decode(String base64Str) {
    try {
      return base64Decode(base64Str) as Uint8List;
    } catch (e) {
      print('Invalid Base64: $e');
      return null;
    }
  }




}

// Repository class for handling CRUD operations
class PurchaseRepository {
  static final CollectionReference _purchaseCollection =
    FirebaseFirestore.instance.collection('PurchaseHistory');

  static Future<List<PurchaseHistoryModel>> getUserPurchases(String userId) async {
    try {

      // Step 1: Build the correct reference
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('User')
          .doc(userId); // This must match the one saved in the reference field


      QuerySnapshot querySnapshot = await _purchaseCollection
          .where('UserId', isEqualTo: userRef)
          .orderBy('PurchaseDate', descending: true)
          .get();

   var data= querySnapshot.docs
          .map((doc) => PurchaseHistoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

   print(data);
      return data;
    } catch (e) {
      print('Error getting user purchases: $e');
      return [];
    }
  }

  // Add purchase record
  static Future<bool> addPurchase(PurchaseHistoryModel purchase) async {
    try {
      await _purchaseCollection.add(purchase.toMap());
      return true;
    } catch (e) {
      print('Error adding purchase: $e');
      return false;
    }
  }

  // Get all purchases (for admin)
  static Future<List<PurchaseHistoryModel>> getAllPurchases() async {
    try {
      QuerySnapshot querySnapshot = await _purchaseCollection
          .orderBy('PurchaseDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PurchaseHistoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting all purchases: $e');
      return [];
    }
  }
}

// Product Repository to work with your existing ProductModel
class ProductRepository {
  static final CollectionReference _productCollection =
  FirebaseFirestore.instance.collection('Books');

  // Get product by ID
  static Future<ProductModel?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await _productCollection.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // Get all products
  static Future<List<ProductModel>> getAllProducts() async {
    try {
      QuerySnapshot querySnapshot = await _productCollection.get();
      return ProductModel.fromQuerySnapshot(querySnapshot);
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  // Add product
  static Future<bool> addProduct(ProductModel product) async {
    try {
      await _productCollection.add(product.toMap());
      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  // Update product
  static Future<bool> updateProduct(String productId, ProductModel product) async {
    try {
      await _productCollection.doc(productId).update(product.toMap());
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // Delete product
  static Future<bool> deleteProduct(String productId) async {
    try {
      await _productCollection.doc(productId).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }
}