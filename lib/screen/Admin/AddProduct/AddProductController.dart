import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:project/screen/model/CategoryModel.dart';
import 'package:project/screen/model/ProductModel.dart';



class AddroductController {

  late BuildContext context;

  AddroductController({required this.context});

  // Main function to register a product
  Future<bool> AddProduct(ProductModel prodmodel) async {

    //prodmodel.categoryid is ka ander name retrieve hoga id tum ko set krna hoga

    if (prodmodel != null) {
      try {
        final snapshot = await FirebaseFirestore.instance.collection(
            'categories').get();

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



      }
catch (e) {
        print('Error fetching products: $e');
        // return [];

      }


      try {




        await FirebaseFirestore.instance
            .collection('Books')
            .add(prodmodel.toMap());


          return true;


      } catch (ex) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong!...Your image is too large"),
            backgroundColor: Colors.red,
          ),
        );

        print("Error adding product: $ex");
        return false;
      }

      // Call to actual database function
    }

    return false;
  }

}