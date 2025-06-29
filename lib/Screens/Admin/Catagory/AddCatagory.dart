// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../Models/CategoryModel.dart';
// import 'dart:convert';
// import 'dart:typed_data'; // ✅
//
// class CategoryController extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String _collectionName = 'categories';
//
//   List<CategoryModel> _categories = [];
//   bool _isLoading = false;
//   String? _errorMessage;
//   CategoryModel? _selectedCategory;
//
//   // Getters
//   List<CategoryModel> get categories => _categories;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   CategoryModel? get selectedCategory => _selectedCategory;
//
//   // Set loading state
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }
//
//   // Set error message
//   void _setError(String? error) {
//     _errorMessage = error;
//     notifyListeners();
//   }
//
//   // Clear error message
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
//
//   // Set selected category
//   void setSelectedCategory(CategoryModel? category) {
//     _selectedCategory = category;
//     notifyListeners();
//   }
//
//   // Create a new category
//   Future<bool> createCategory(String categoryName) async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       // Validate input
//       if (categoryName.trim().isEmpty) {
//         _setError('Category name cannot be empty');
//         return false;
//       }
//
//       // Check if category already exists
//       bool exists = await _categoryExists(categoryName.trim());
//       if (exists) {
//         _setError('Category already exists');
//         return false;
//       }
//
//       // Create new category
//       CategoryModel newCategory = CategoryModel(
//         categoriesname: categoryName.trim(), docId: '',
//       );
//
//       // Add to Firestore
//       DocumentReference docRef = await _firestore
//           .collection(_collectionName)
//           .add(newCategory.toMap());
//
//       // Update local list
//       newCategory.docId = docRef.id;
//       _categories.add(newCategory);
//
//       _setError(null);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError('Failed to create category: ${e.toString()}');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Read all categories
//   Future<void> fetchCategories() async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       QuerySnapshot querySnapshot = await _firestore
//           .collection(_collectionName)
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       _categories = querySnapshot.docs
//           .map((doc) => CategoryModel.fromSnapshot(doc))
//           .toList();
//
//       _setError(null);
//     } catch (e) {
//       _setError('Failed to fetch categories: ${e.toString()}');
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Update category
//   Future<bool> updateCategory(String categoryId, String newCategoryName) async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       // Validate input
//       if (newCategoryName.trim().isEmpty) {
//         _setError('Category name cannot be empty');
//         return false;
//       }
//
//       // Check if category already exists (excluding current category)
//       bool exists = await _categoryExists(newCategoryName.trim(), excludeId: categoryId);
//       if (exists) {
//         _setError('Category already exists');
//         return false;
//       }
//
//       // Update in Firestore
//       await _firestore.collection(_collectionName).doc(categoryId).update({
//         'categoriesname': newCategoryName.trim(),
//         'updatedAt': Timestamp.fromDate(DateTime.now()),
//       });
//
//       // Update local list
//       int index = _categories.indexWhere((cat) => cat.docId == categoryId);
//       if (index != -1) {
//         _categories[index] = _categories[index].copyWith(
//           categoriesname: newCategoryName.trim(),
//         );
//       }
//
//       _setError(null);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError('Failed to update category: ${e.toString()}');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Delete category
//   Future<bool> deleteCategory(String categoryId) async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       // Delete from Firestore
//       await _firestore.collection(_collectionName).doc(categoryId).delete();
//
//       // Remove from local list
//       _categories.removeWhere((cat) => cat.docId == categoryId);
//
//       _setError(null);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError('Failed to delete category: ${e.toString()}');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Search categories
//   List<CategoryModel> searchCategories(String query) {
//     if (query.isEmpty) return _categories;
//
//     return _categories
//         .where((category) => category.categoriesname
//             .toLowerCase()
//             .contains(query.toLowerCase()))
//         .toList();
//   }
//
//   // Get category by ID
//   CategoryModel? getCategoryById(String categoryId) {
//     try {
//       return _categories.firstWhere((cat) => cat.docId == categoryId);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // Check if category exists
//   Future<bool> _categoryExists(String categoryName, {String? excludeId}) async {
//     try {
//       Query query = _firestore
//           .collection(_collectionName)
//           .where('categoriesname', isEqualTo: categoryName.trim());
//
//       QuerySnapshot querySnapshot = await query.get();
//
//       if (excludeId != null) {
//         return querySnapshot.docs.any((doc) => doc.id != excludeId);
//       }
//
//       return querySnapshot.docs.isNotEmpty;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   // Get categories count
//   int get categoriesCount => _categories.length;
//
//   // Real-time listener for categories
//   Stream<List<CategoryModel>> getCategoriesStream() {
//     return _firestore
//         .collection(_collectionName)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => CategoryModel.fromSnapshot(doc))
//             .toList());
//   }
//
//   // Batch delete categories
//   Future<bool> deleteMultipleCategories(List<String> categoryIds) async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       WriteBatch batch = _firestore.batch();
//
//       for (String categoryId in categoryIds) {
//         DocumentReference docRef = _firestore.collection(_collectionName).doc(categoryId);
//         batch.delete(docRef);
//       }
//
//       await batch.commit();
//
//       // Remove from local list
//       _categories.removeWhere((cat) => categoryIds.contains(cat.docId));
//
//       _setError(null);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError('Failed to delete categories: ${e.toString()}');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Dispose method
//   @override
//   void dispose() {
//     super.dispose();
//   }
// }


 import '../../Models/CategoryModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// class CategoryController extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String _collectionName = 'categories';
//
//   List<CategoryModel> _categories = [];
//   bool _isLoading = false;
//   String? _errorMessage;
//   CategoryModel? _selectedCategory;
//
//   // Getters
//   List<CategoryModel> get categories => _categories;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   CategoryModel? get selectedCategory => _selectedCategory;
//
//   // Set loading state
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }
//
//   // Set error message
//   void _setError(String? error) {
//     _errorMessage = error;
//     notifyListeners();
//   }
//
//   // Clear error message
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
//
//   // Set selected category
//   void setSelectedCategory(CategoryModel? category) {
//     _selectedCategory = category;
//     notifyListeners();
//   }
//
//   // Create a new category
//   Future<bool> createCategory(String categoryName) async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       // Validate input
//       if (categoryName.trim().isEmpty) {
//         _setError('Category name cannot be empty');
//         return false;
//       }
//
//       // Check if category already exists
//       bool exists = await _categoryExists(categoryName.trim());
//       if (exists) {
//         _setError('Category already exists');
//         return false;
//       }
//
//       // Create new category
//       CategoryModel newCategory = CategoryModel(
//         categoriesname: categoryName.trim(), docId: 'rtrt',
//       );
//
//       // Add to Firestore
//       DocumentReference docRef = await _firestore
//           .collection(_collectionName)
//           .add(newCategory.toMap());
//
//       // Update local list
//       newCategory.docId = docRef.id;
//       _categories.add(newCategory);
//
//       _setError(null);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError('Failed to create category: ${e.toString()}');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Read all categories
//   Future<void> fetchCategories() async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       QuerySnapshot querySnapshot = await _firestore
//           .collection(_collectionName)
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       _categories = querySnapshot.docs
//           .map((doc) => CategoryModel.fromSnapshot(doc))
//           .toList();
//
//       _setError(null);
//     } catch (e) {
//       _setError('Failed to fetch categories: ${e.toString()}');
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Update category
//   Future<bool> updateCategory(String categoryId, String newCategoryName) async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       // Validate input
//       if (newCategoryName.trim().isEmpty) {
//         _setError('Category name cannot be empty');
//         return false;
//       }
//
//       // Check if category already exists (excluding current category)
//       bool exists = await _categoryExists(newCategoryName.trim(), excludeId: categoryId);
//       if (exists) {
//         _setError('Category already exists');
//         return false;
//       }
//
//       // Update in Firestore
//       await _firestore.collection(_collectionName).doc(categoryId).update({
//         'categoriesname': newCategoryName.trim(),
//         'updatedAt': Timestamp.fromDate(DateTime.now()),
//       });
//
//       // Update local list
//       int index = _categories.indexWhere((cat) => cat.docId == categoryId);
//       if (index != -1) {
//         _categories[index] = _categories[index].copyWith(
//           categoriesname: newCategoryName.trim(),
//         );
//       }
//
//       _setError(null);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError('Failed to update category: ${e.toString()}');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Delete category
//   Future<bool> deleteCategory(String categoryId) async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       // Delete from Firestore
//       await _firestore.collection(_collectionName).doc(categoryId).delete();
//
//       // Remove from local list
//       _categories.removeWhere((cat) => cat.docId == categoryId);
//
//       _setError(null);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError('Failed to delete category: ${e.toString()}');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Search categories
//   List<CategoryModel> searchCategories(String query) {
//     if (query.isEmpty) return _categories;
//
//     return _categories
//         .where((category) => category.categoriesname
//         .toLowerCase()
//         .contains(query.toLowerCase()))
//         .toList();
//   }
//
//   // Get category by ID
//   CategoryModel? getCategoryById(String categoryId) {
//     try {
//       return _categories.firstWhere((cat) => cat.docId == categoryId);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // Check if category exists
//   Future<bool> _categoryExists(String categoryName, {String? excludeId}) async {
//     try {
//       Query query = _firestore
//           .collection(_collectionName)
//           .where('categoriesname', isEqualTo: categoryName.trim());
//
//       QuerySnapshot querySnapshot = await query.get();
//
//       if (excludeId != null) {
//         return querySnapshot.docs.any((doc) => doc.id != excludeId);
//       }
//
//       return querySnapshot.docs.isNotEmpty;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   // Get categories count
//   int get categoriesCount => _categories.length;
//
//   // Real-time listener for categories
//   Stream<List<CategoryModel>> getCategoriesStream() {
//     return _firestore
//         .collection(_collectionName)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => CategoryModel.fromSnapshot(doc))
//         .toList());
//   }
//
//   // Batch delete categories
//   Future<bool> deleteMultipleCategories(List<String> categoryIds) async {
//     try {
//       _setLoading(true);
//       _setError(null);
//
//       WriteBatch batch = _firestore.batch();
//
//       for (String categoryId in categoryIds) {
//         DocumentReference docRef = _firestore.collection(_collectionName).doc(categoryId);
//         batch.delete(docRef);
//       }
//
//       await batch.commit();
//
//       // Remove from local list
//       _categories.removeWhere((cat) => categoryIds.contains(cat.docId));
//
//       _setError(null);
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError('Failed to delete categories: ${e.toString()}');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }
//
//   // Dispose method
//   @override
//   void dispose() {
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CategoryController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'categories';

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  CategoryModel? _selectedCategory;

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CategoryModel? get selectedCategory => _selectedCategory;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(CategoryModel? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Create a new category
  Future<bool> createCategory(String categoryName) async {
    try {
      _setLoading(true);
      _setError(null);

      // Validate input
      if (categoryName.trim().isEmpty) {
        _setError('Category name cannot be empty');
        return false;
      }

      // Check if category already exists
      bool exists = await _categoryExists(categoryName.trim());
      if (exists) {
        _setError('Category already exists');
        return false;
      }

      // Create new category
      CategoryModel newCategory = CategoryModel(
        categoriesname: categoryName.trim(),
      );

      // Add to Firestore
      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(newCategory.toMap());

      // Update local list
      newCategory.id = docRef.id;
      _categories.add(newCategory);

      _setError(null);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create category: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Read all categories
  Future<void> fetchCategories() async {
    try {
      _setLoading(true);
      _setError(null);

      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      _categories = querySnapshot.docs
          .map((doc) => CategoryModel.fromSnapshot(doc))
          .toList();

      _setError(null);
    } catch (e) {
      _setError('Failed to fetch categories: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update category
  Future<bool> updateCategory(String categoryId, String newCategoryName) async {
    try {
      _setLoading(true);
      _setError(null);

      // Validate input
      if (newCategoryName.trim().isEmpty) {
        _setError('Category name cannot be empty');
        return false;
      }

      // Check if category already exists (excluding current category)
      bool exists = await _categoryExists(newCategoryName.trim(), excludeId: categoryId);
      if (exists) {
        _setError('Category already exists');
        return false;
      }

      // Update in Firestore
      await _firestore.collection(_collectionName).doc(categoryId).update({
        'categoriesname': newCategoryName.trim(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update local list
      int index = _categories.indexWhere((cat) => cat.id == categoryId);
      if (index != -1) {
        _categories[index] = _categories[index].copyWith(
          categoriesname: newCategoryName.trim(),
        );
      }

      _setError(null);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update category: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      _setLoading(true);
      _setError(null);

      // Delete from Firestore
      await _firestore.collection(_collectionName).doc(categoryId).delete();

      // Remove from local list
      _categories.removeWhere((cat) => cat.id == categoryId);

      _setError(null);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete category: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search categories
  List<CategoryModel> searchCategories(String query) {
    if (query.isEmpty) return _categories;

    return _categories
        .where((category) => category.categoriesname
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
  }

  // Get category by ID
  CategoryModel? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Check if category exists
  Future<bool> _categoryExists(String categoryName, {String? excludeId}) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('categoriesname', isEqualTo: categoryName.trim());

      QuerySnapshot querySnapshot = await query.get();

      if (excludeId != null) {
        return querySnapshot.docs.any((doc) => doc.id != excludeId);
      }

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get categories count
  int get categoriesCount => _categories.length;

  // Real-time listener for categories
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CategoryModel.fromSnapshot(doc))
        .toList());
  }

  // Batch delete categories
  Future<bool> deleteMultipleCategories(List<String> categoryIds) async {
    try {
      _setLoading(true);
      _setError(null);

      WriteBatch batch = _firestore.batch();

      for (String categoryId in categoryIds) {
        DocumentReference docRef = _firestore.collection(_collectionName).doc(categoryId);
        batch.delete(docRef);
      }

      await batch.commit();

      // Remove from local list
      _categories.removeWhere((cat) => categoryIds.contains(cat.id));

      _setError(null);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete categories: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Dispose method
  @override
  void dispose() {
    super.dispose();
  }
}