import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/screen/model/CategoryModel.dart';
import 'package:project/screen/model/ProductModel.dart';

class UpdateProductController {
  late BuildContext context;

  UpdateProductController({required this.context});

  // Update product function
  Future<bool> updateProduct(ProductModel prodmodel, String productId) async {
    if (prodmodel != null && productId.isNotEmpty) {
      try {
        // Get category ID from category name
        final snapshot = await FirebaseFirestore.instance.collection('categories').get();
        final categoryDocs = snapshot.docs;
        final categoriesList = categoryDocs.map((doc) {
          return CategoryModel.fromSnapshot(doc);
        }).toList();

        final matchedCategory = categoriesList.firstWhere(
              (category) => category?.categoriesname == prodmodel.categoryid
        );

        if (matchedCategory != null) {
          final realselectedCategoryId = matchedCategory.id;
          prodmodel.categoryid = realselectedCategoryId;
        }

        // Update the product in Firestore
        await FirebaseFirestore.instance
            .collection('Books')
            .doc(productId)
            .update(prodmodel.toMap());

        return true;
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong! Error: $ex"),
            backgroundColor: Colors.red,
          ),
        );
        print("Error updating product: $ex");
        return false;
      }
    }
    return false;
  }

  // Get product by ID for editing
  Future<ProductModel?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Books')
          .doc(productId)
          .get();
      
      if (doc.exists) {
        return ProductModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print("Error fetching product: $e");
      return null;
    }
  }

  // Get category name by ID
  Future<String> getCategoryNameById(String categoryId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .get();
      
      if (doc.exists) {
        return doc['categoriesname'] ?? '';
      }
      return '';
    } catch (e) {
      print("Error fetching category: $e");
      return '';
    }
  }
}