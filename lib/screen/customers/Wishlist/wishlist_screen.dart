import 'package:flutter/material.dart';
import 'package:project/screen/customers/Wishlist/wishlist_controller.dart';
import 'package:project/screen/customers/Wishlist/wishlist_item_card.dart';
import 'package:project/screen/customers/animated_app_bar.dart';
import 'package:project/screen/model/ProductModel.dart';
import 'package:project/screen/model/wishlist_model.dart';
import '../Cart/cart_controller.dart';
import '../Cart/cart_screen.dart';
import '../CustomerProfileUpdate/customer_profile_update_screen.dart';
import '../Home/home_controller.dart';
import '../Home/home_view.dart';
import '../Home/profile_avatar_widget.dart';
import '../base_customer_screen.dart';

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
      List<WishlistModel> wishlistItems = (await _wishlistController.getWishlistItems()).cast<WishlistModel>();
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
      appBar: AnimatedAppBar(),

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

        bottomNavigationBar: EnhancedBottomNavigation(currentIndex: 4,)
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