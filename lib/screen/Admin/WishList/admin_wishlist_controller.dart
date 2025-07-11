import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/ProductModel.dart';
import 'package:project/screen/model/Users.dart';
import 'package:project/screen/model/wishlist_model.dart';


class AdminWishlistController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all wishlist items with user and product details
  Future<List<AdminWishlistItem>> getAllWishlistItems() async {
    try {
      print('🔄 Fetching all wishlist items...');

      QuerySnapshot wishlistSnapshot = await _firestore
          .collection('WishList')
          .where('isFavorite', isEqualTo: true)
          .orderBy('addedAt', descending: true)
          .get();

      List<AdminWishlistItem> adminWishlistItems = [];

      for (DocumentSnapshot wishlistDoc in wishlistSnapshot.docs) {
        try {
          WishlistModel wishlistItem = WishlistModel.fromSnapshot(wishlistDoc);

          // Get user details using your UsersRepository
          UsersModel? user = await UsersRepository.getUserById(wishlistItem.userId);

          // Get product details using your ProductRepository
          ProductModel? product = await ProductRepository.getProductById(wishlistItem.productId);

          if (user != null && product != null) {
            adminWishlistItems.add(AdminWishlistItem(
              wishlistItem: wishlistItem,
              user: user,
              product: product,
            ));
          }
        } catch (e) {
          print('❌ Error processing wishlist item: $e');
        }
      }

      print('✅ Fetched ${adminWishlistItems.length} wishlist items');
      return adminWishlistItems;
    } catch (e) {
      print('❌ Error fetching wishlist items: $e');
      return [];
    }
  }

  // Get wishlist statistics
  Future<WishlistStats> getWishlistStats() async {
    try {
      QuerySnapshot allWishlist = await _firestore
          .collection('WishList')
          .where('isFavorite', isEqualTo: true)
          .get();

      // Get unique users count
      Set<String> uniqueUsers = {};
      Map<String, int> productCounts = {};
      int totalWithNotes = 0;

      for (DocumentSnapshot doc in allWishlist.docs) {
        WishlistModel item = WishlistModel.fromSnapshot(doc);
        uniqueUsers.add(item.userId);

        // Count products
        productCounts[item.productId] = (productCounts[item.productId] ?? 0) + 1;

        // Count items with notes
        if (item.notes != null && item.notes!.trim().isNotEmpty) {
          totalWithNotes++;
        }
      }

      // Find most wishlisted product
      String? mostWishlistedProductId;
      int maxCount = 0;
      productCounts.forEach((productId, count) {
        if (count > maxCount) {
          maxCount = count;
          mostWishlistedProductId = productId;
        }
      });

      ProductModel? mostWishlistedProduct;
      if (mostWishlistedProductId != null) {
        mostWishlistedProduct = await ProductRepository.getProductById(mostWishlistedProductId??'Not here');
      }

      return WishlistStats(
        totalItems: allWishlist.docs.length,
        uniqueUsers: uniqueUsers.length,
        itemsWithNotes: totalWithNotes,
        mostWishlistedProduct: mostWishlistedProduct,
        mostWishlistedCount: maxCount,
      );
    } catch (e) {
      print('❌ Error getting wishlist stats: $e');
      return WishlistStats(
        totalItems: 0,
        uniqueUsers: 0,
        itemsWithNotes: 0,
        mostWishlistedProduct: null,
        mostWishlistedCount: 0,
      );
    }
  }

  // Search wishlist items
  Future<List<AdminWishlistItem>> searchWishlistItems(String query) async {
    try {
      List<AdminWishlistItem> allItems = await getAllWishlistItems();

      if (query.isEmpty) return allItems;

      String lowerQuery = query.toLowerCase();

      return allItems.where((item) {
        return item.product.name.toLowerCase().contains(lowerQuery) ||
            item.user.userName.toLowerCase().contains(lowerQuery) ||
            item.user.email.toLowerCase().contains(lowerQuery) ||
            (item.wishlistItem.notes?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      print('❌ Error searching wishlist items: $e');
      return [];
    }
  }

  // Delete wishlist item
  Future<bool> deleteWishlistItem(String userId, String productId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('WishList')
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
        print('✅ Wishlist item deleted');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting wishlist item: $e');
      return false;
    }
  }

  // Get wishlist items by user
  Future<List<AdminWishlistItem>> getWishlistItemsByUser(String userId) async {
    try {
      QuerySnapshot wishlistSnapshot = await _firestore
          .collection('WishList')
          .where('userId', isEqualTo: userId)
          .where('isFavorite', isEqualTo: true)
          .orderBy('addedAt', descending: true)
          .get();

      List<AdminWishlistItem> userWishlistItems = [];

      for (DocumentSnapshot wishlistDoc in wishlistSnapshot.docs) {
        try {
          WishlistModel wishlistItem = WishlistModel.fromSnapshot(wishlistDoc);

          // Get user details
          UsersModel? user = await UsersRepository.getUserById(wishlistItem.userId);

          // Get product details
          ProductModel? product = await ProductRepository.getProductById(wishlistItem.productId);

          if (user != null && product != null) {
            userWishlistItems.add(AdminWishlistItem(
              wishlistItem: wishlistItem,
              user: user,
              product: product,
            ));
          }
        } catch (e) {
          print('❌ Error processing user wishlist item: $e');
        }
      }

      return userWishlistItems;
    } catch (e) {
      print('❌ Error fetching user wishlist items: $e');
      return [];
    }
  }

  // Get most popular products in wishlist
  Future<List<PopularProduct>> getMostPopularWishlistProducts({int limit = 10}) async {
    try {
      QuerySnapshot allWishlist = await _firestore
          .collection('WishList')
          .where('isFavorite', isEqualTo: true)
          .get();

      Map<String, int> productCounts = {};

      for (DocumentSnapshot doc in allWishlist.docs) {
        WishlistModel item = WishlistModel.fromSnapshot(doc);
        productCounts[item.productId] = (productCounts[item.productId] ?? 0) + 1;
      }

      // Sort by count and get top products
      var sortedProducts = productCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      List<PopularProduct> popularProducts = [];

      for (var entry in sortedProducts.take(limit)) {
        ProductModel? product = await ProductRepository.getProductById(entry.key);
        if (product != null) {
          popularProducts.add(PopularProduct(
            product: product,
            wishlistCount: entry.value,
          ));
        }
      }

      return popularProducts;
    } catch (e) {
      print('❌ Error getting popular products: $e');
      return [];
    }
  }
}

// Helper classes
class AdminWishlistItem {
  final WishlistModel wishlistItem;
  final UsersModel user;
  final ProductModel product;

  AdminWishlistItem({
    required this.wishlistItem,
    required this.user,
    required this.product,
  });
}

class WishlistStats {
  final int totalItems;
  final int uniqueUsers;
  final int itemsWithNotes;
  final ProductModel? mostWishlistedProduct;
  final int mostWishlistedCount;

  WishlistStats({
    required this.totalItems,
    required this.uniqueUsers,
    required this.itemsWithNotes,
    required this.mostWishlistedProduct,
    required this.mostWishlistedCount,
  });
}

class PopularProduct {
  final ProductModel product;
  final int wishlistCount;

  PopularProduct({
    required this.product,
    required this.wishlistCount,
  });
}



// class AdminWishlistController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Get all wishlist items with user and product details
//   Future<List<AdminWishlistItem>> getAllWishlistItems() async {
//     try {
//       print('🔄 Fetching all wishlist items...');
//
//       QuerySnapshot wishlistSnapshot = await _firestore
//           .collection('WishList')
//           .where('isFavorite', isEqualTo: true)
//           .orderBy('addedAt', descending: true)
//           .get();
//
//       List<AdminWishlistItem> adminWishlistItems = [];
//
//       for (DocumentSnapshot wishlistDoc in wishlistSnapshot.docs) {
//         try {
//           WishlistModel wishlistItem = WishlistModel.fromSnapshot(wishlistDoc);
//
//           // Get user details
//           UsersModel? user = await _getUserById(wishlistItem.userId);
//
//           // Get product details
//           ProductModel? product = await _getProductById(wishlistItem.productId);
//
//           if (user != null && product != null) {
//             adminWishlistItems.add(AdminWishlistItem(
//               wishlistItem: wishlistItem,
//               user: user,
//               product: product,
//             ));
//           }
//         } catch (e) {
//           print('❌ Error processing wishlist item: $e');
//         }
//       }
//
//       print('✅ Fetched ${adminWishlistItems.length} wishlist items');
//       return adminWishlistItems;
//     } catch (e) {
//       print('❌ Error fetching wishlist items: $e');
//       return [];
//     }
//   }
//
//   // Get user by ID
//   Future<UsersModel?> _getUserById(String userId) async {
//     try {
//       DocumentSnapshot userDoc = await _firestore
//           .collection('Users')
//           .doc(userId)
//           .get();
//
//       if (userDoc.exists) {
//         return UsersModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
//       }
//       return null;
//     } catch (e) {
//       print('❌ Error fetching user: $e');
//       return null;
//     }
//   }
//
//   // Get product by ID
//   Future<ProductModel?> _getProductById(String productId) async {
//     try {
//       DocumentSnapshot productDoc = await _firestore
//           .collection('Products')
//           .doc(productId)
//           .get();
//
//       if (productDoc.exists) {
//         return ProductModel.fromSnapshot(productDoc);
//       }
//       return null;
//     } catch (e) {
//       print('❌ Error fetching product: $e');
//       return null;
//     }
//   }
//
//   // Get wishlist statistics
//   Future<WishlistStats> getWishlistStats() async {
//     try {
//       QuerySnapshot allWishlist = await _firestore
//           .collection('WishList')
//           .where('isFavorite', isEqualTo: true)
//           .get();
//
//       // Get unique users count
//       Set<String> uniqueUsers = {};
//       Map<String, int> productCounts = {};
//       int totalWithNotes = 0;
//
//       for (DocumentSnapshot doc in allWishlist.docs) {
//         WishlistModel item = WishlistModel.fromSnapshot(doc);
//         uniqueUsers.add(item.userId);
//
//         // Count products
//         productCounts[item.productId] = (productCounts[item.productId] ?? 0) + 1;
//
//         // Count items with notes
//         if (item.notes != null && item.notes!.trim().isNotEmpty) {
//           totalWithNotes++;
//         }
//       }
//
//       // Find most wishlisted product
//       String? mostWishlistedProductId;
//       int maxCount = 0;
//       productCounts.forEach((productId, count) {
//         if (count > maxCount) {
//           maxCount = count;
//           mostWishlistedProductId = productId;
//         }
//       });
//
//       ProductModel? mostWishlistedProduct;
//       if (mostWishlistedProductId != null) {
//         mostWishlistedProduct = await _getProductById(mostWishlistedProductId??'None Found');
//       }
//
//       return WishlistStats(
//         totalItems: allWishlist.docs.length,
//         uniqueUsers: uniqueUsers.length,
//         itemsWithNotes: totalWithNotes,
//         mostWishlistedProduct: mostWishlistedProduct,
//         mostWishlistedCount: maxCount,
//       );
//     } catch (e) {
//       print('❌ Error getting wishlist stats: $e');
//       return WishlistStats(
//         totalItems: 0,
//         uniqueUsers: 0,
//         itemsWithNotes: 0,
//         mostWishlistedProduct: null,
//         mostWishlistedCount: 0,
//       );
//     }
//   }
//
//   // Search wishlist items
//   Future<List<AdminWishlistItem>> searchWishlistItems(String query) async {
//     try {
//       List<AdminWishlistItem> allItems = await getAllWishlistItems();
//
//       if (query.isEmpty) return allItems;
//
//       String lowerQuery = query.toLowerCase();
//
//       return allItems.where((item) {
//         return item.product.name?.toLowerCase().contains(lowerQuery) == true ||
//                item.user.userName?.toLowerCase().contains(lowerQuery) == true ||
//                item.user.email?.toLowerCase().contains(lowerQuery) == true ||
//                item.wishlistItem.notes?.toLowerCase().contains(lowerQuery) == true;
//       }).toList();
//     } catch (e) {
//       print('❌ Error searching wishlist items: $e');
//       return [];
//     }
//   }
//
//   // Delete wishlist item
//   Future<bool> deleteWishlistItem(String userId, String productId) async {
//     try {
//       QuerySnapshot snapshot = await _firestore
//           .collection('WishList')
//           .where('userId', isEqualTo: userId)
//           .where('productId', isEqualTo: productId)
//           .get();
//
//       if (snapshot.docs.isNotEmpty) {
//         await snapshot.docs.first.reference.delete();
//         print('✅ Wishlist item deleted');
//         return true;
//       }
//       return false;
//     } catch (e) {
//       print('❌ Error deleting wishlist item: $e');
//       return false;
//     }
//   }
// }
//
// // Helper classes
// class AdminWishlistItem {
//   final WishlistModel wishlistItem;
//   final UsersModel user;
//   final ProductModel product;
//
//   AdminWishlistItem({
//     required this.wishlistItem,
//     required this.user,
//     required this.product,
//   });
// }
//
// class WishlistStats {
//   final int totalItems;
//   final int uniqueUsers;
//   final int itemsWithNotes;
//   final ProductModel? mostWishlistedProduct;
//   final int mostWishlistedCount;
//
//   WishlistStats({
//     required this.totalItems,
//     required this.uniqueUsers,
//     required this.itemsWithNotes,
//     required this.mostWishlistedProduct,
//     required this.mostWishlistedCount,
//   });
// }