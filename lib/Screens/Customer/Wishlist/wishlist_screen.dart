import 'package:flutter/material.dart';
import 'package:project/Screens/Customer/Wishlist/wishlist_controller.dart';
import 'package:project/Screens/Customer/Wishlist/wishlist_item_card.dart';

import '../../Models/ProductModel.dart';
import '../../Models/wishlist_model.dart';
import '../Cart/cart_controller.dart';
import '../Cart/cart_screen.dart';
import '../CustomerProfileUpdate/customer_profile_update_screen.dart';
import '../Home/home_controller.dart';
import '../Home/home_view.dart';
import '../Home/profile_avatar_widget.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  int _selectedIndex = 3; // Wishlist tab
  final WishlistController _wishlistController = WishlistController();
  final HomeController _homeController = HomeController();
  final CartController _cartController = CartController();
  
  List<WishlistItemWithProduct> _wishlistItems = [];
  bool _isLoading = true;
  int _cartItemsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
    _updateCartCount();
  }

  Future<void> _loadWishlistItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<WishlistModel> wishlistItems = await _wishlistController.getWishlistItems();
      List<WishlistItemWithProduct> itemsWithProducts = [];

      for (WishlistModel wishlistItem in wishlistItems) {
        ProductModel? product = await _homeController.getProductById(wishlistItem.productId);
        if (product != null) {
          itemsWithProducts.add(WishlistItemWithProduct(
            wishlistItem: wishlistItem,
            product: product,
          ));
        }
      }

      setState(() {
        _wishlistItems = itemsWithProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading wishlist items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCartCount() async {
    try {
      int count = await _cartController.getCartCount();
      if (mounted) {
        setState(() {
          _cartItemsCount = count;
        });
      }
    } catch (e) {
      print('Error updating cart count: $e');
    }
  }

  Future<void> _removeFromWishlist(String productId) async {
    bool success = await _wishlistController.removeFromWishlist(productId);
    if (success) {
      _loadWishlistItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💔 Removed from wishlist'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearWishlist() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Wishlist'),
          content: const Text('Are you sure you want to remove all items from your wishlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                bool success = await _wishlistController.clearWishlist();
                if (success) {
                  _loadWishlistItems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('💔 Wishlist cleared'),
                      backgroundColor: Colors.black,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Wishlist',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      ProfileAvatarWidget(
                        onLoginRequired: () {
                          // Handle login navigation
                        },
                        onLogoutSuccess: () {
                          _loadWishlistItems();
                          _updateCartCount();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_wishlistItems.length} items in wishlist',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_wishlistItems.isNotEmpty)
                        TextButton.icon(
                          onPressed: _clearWishlist,
                          icon: const Icon(Icons.clear_all, color: Colors.red, size: 18),
                          label: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Wishlist Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _wishlistItems.isEmpty
                      ? _buildEmptyWishlist()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _wishlistItems.length,
                          itemBuilder: (context, index) {
                            return WishlistItemCard(
                              item: _wishlistItems[index],
                              onRemove: () => _removeFromWishlist(_wishlistItems[index].product.id!),
                              onCartUpdated: _updateCartCount,
                              onNotesUpdated: _loadWishlistItems,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),


      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });
      //
      //     switch (index) {
      //       case 0:
      //         Navigator.pushReplacement(
      //           context,
      //           MaterialPageRoute(builder: (context) => const Home()),
      //         );
      //         break;
      //       case 1:
      //         // Navigate to Top Trends
      //         break;
      //       case 2:
      //         Navigator.pushReplacement(
      //           context,
      //           MaterialPageRoute(builder: (context) => const CartScreen()),
      //         );
      //         break;
      //       case 3:
      //         // Already on Wishlist
      //         break;
      //       case 4:
      //         // Navigate to Profile
      //         break;
      //     }
      //   },
      //   type: BottomNavigationBarType.fixed,
      //   selectedItemColor: Colors.black,
      //   unselectedItemColor: Colors.grey,
      //   showSelectedLabels: true,
      //   showUnselectedLabels: true,
      //   items: [
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.home_outlined),
      //       activeIcon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_bag_outlined),
      //       activeIcon: Icon(Icons.shopping_bag),
      //       label: 'Top Trends',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Stack(
      //         children: [
      //           const Icon(Icons.shopping_cart_outlined),
      //           if (_cartItemsCount > 0)
      //             Positioned(
      //               right: 0,
      //               top: 0,
      //               child: Container(
      //                 padding: const EdgeInsets.all(2),
      //                 decoration: BoxDecoration(
      //                   color: Colors.red.shade400,
      //                   borderRadius: BorderRadius.circular(10),
      //                 ),
      //                 constraints: const BoxConstraints(
      //                   minWidth: 16,
      //                   minHeight: 16,
      //                 ),
      //                 child: Text(
      //                   '$_cartItemsCount',
      //                   style: const TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 10,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                   textAlign: TextAlign.center,
      //                 ),
      //               ),
      //             ),
      //         ],
      //       ),
      //       activeIcon: Stack(
      //         children: [
      //           const Icon(Icons.shopping_cart),
      //           if (_cartItemsCount > 0)
      //             Positioned(
      //               right: 0,
      //               top: 0,
      //               child: Container(
      //                 padding: const EdgeInsets.all(2),
      //                 decoration: BoxDecoration(
      //                   color: Colors.red,
      //                   borderRadius: BorderRadius.circular(10),
      //                 ),
      //                 constraints: const BoxConstraints(
      //                   minWidth: 16,
      //                   minHeight: 16,
      //                 ),
      //                 child: Text(
      //                   '$_cartItemsCount',
      //                   style: const TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 10,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                   textAlign: TextAlign.center,
      //                 ),
      //               ),
      //             ),
      //         ],
      //       ),
      //       label: 'Cart',
      //     ),
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.favorite_outline),
      //       activeIcon: Icon(Icons.favorite, color: Colors.red),
      //       label: 'Wishlist',
      //     ),
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.person_outline),
      //       activeIcon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      // ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
            // Already on Home
              break;
            case 1:
            // Navigate to Top Trends
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const   CustomerProfileUpdateScreen()),
              );

              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Top Trends',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (_cartItemsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_cartItemsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartItemsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_cartItemsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite, color: Colors.red),
            label: 'Wishlist',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Double-tap on products to add them to your wishlist',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }
}

// Helper class to combine wishlist item with product details
class WishlistItemWithProduct {
  final WishlistModel wishlistItem;
  final ProductModel product;

  WishlistItemWithProduct({
    required this.wishlistItem,
    required this.product,
  });
}