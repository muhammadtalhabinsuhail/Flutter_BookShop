import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/screen/model/ProductModel.dart';
import 'package:project/screen/model/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CheckOut/checkout_page.dart';
import '../CustomerProfileUpdate/customer_profile_update_screen.dart';
import '../Home/home_controller.dart';

import '../Home/home_view.dart';
import '../Home/profile_avatar_widget.dart';
import '../Wishlist/wishlist_screen.dart';
import '../animated_app_bar.dart';
import '../base_customer_screen.dart';
import 'cart_controller.dart';


class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedIndex = 2;
  final CartController _cartController = CartController();
  final HomeController _homeController = HomeController();
  
  List<CartItemWithProduct> _cartItems = [];
  bool _isLoading = true;
  double _totalPrice = 0.0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<CartModel> cartItems = await _cartController.getCartItems();
      List<CartItemWithProduct> itemsWithProducts = [];

      for (CartModel cartItem in cartItems) {
        ProductModel? product = await _homeController.getProductById(cartItem.productId);
        if (product != null) {
          itemsWithProducts.add(CartItemWithProduct(
            cartItem: cartItem,
            product: product,
          ));
        }
      }

      _calculateTotals(itemsWithProducts);

      setState(() {
        _cartItems = itemsWithProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cart items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateTotals(List<CartItemWithProduct> items) {
    _totalItems = items.fold(0, (sum, item) => sum + item.cartItem.quantity);
    _totalPrice = items.fold(0.0, (sum, item) => sum + item.cartItem.totalPrice);
  }

  Future<void> _updateQuantity(String cartId, int newQuantity, double productPrice) async {
    bool success = await _cartController.updateCartItemQuantity(cartId, newQuantity, productPrice);
    if (success) {
      _loadCartItems(); // Reload to get updated data
    }
  }

  Future<void> _removeItem(String cartId) async {
    bool success = await _cartController.removeCartItem(cartId);
    if (success) {
      _loadCartItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearCart() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                bool success = await _cartController.clearCart();
                if (success) {
                  _loadCartItems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cart cleared successfully'),
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



  // Function to insert in your ElevatedButton onPressed
  Future<void> checkoutCartItems() async {
    try {
      // Get current user email from preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');

      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Get user document by email
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('User')
          .where('Email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
        return;
      }





      String userId = userQuery.docs.first.id;

      // Update all cart items for this user to isCheckedOut: true
      QuerySnapshot cartQuery = await FirebaseFirestore.instance
          .collection('Cart')
          .where('UserId', isEqualTo: userId)
          .where('isCheckedOut', isEqualTo: false)
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (QueryDocumentSnapshot doc in cartQuery.docs) {
        batch.update(doc.reference, {'isCheckedOut': true});
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Proceeding to checkout with $_totalItems items'),
          backgroundColor: Colors.black,
        ),
      );

      // Navigate to checkout page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CheckoutPage()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }




  void _checkout() async{
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }else {
      await checkoutCartItems();
    }



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

                  const SizedBox(height: 24),
                  Text(
                    '${_cartItems.length} items in cart',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Cart Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _cartItems.isEmpty
                      ? _buildEmptyCart()
                      : Column(
                          children: [
                            // Cart Items List
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _cartItems.length,
                                itemBuilder: (context, index) {
                                  return _buildCartItem(_cartItems[index], index);
                                },
                              ),
                            ),

                            // Clear Cart Button
                            if (_cartItems.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                child: OutlinedButton(
                                  onPressed: _clearCart,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Clear Cart',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
            ),

            // Bottom Total Section
            if (_cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total Price',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '\$${_totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Checkout ($_totalItems items)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),

        bottomNavigationBar: EnhancedBottomNavigation(currentIndex: 2,)
    );
  }

  Widget _buildCartItem(CartItemWithProduct item, int index) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
    final DateFormat timeFormat = DateFormat('hh:mm a');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date and Time Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.cartItem.addedItem != null 
                    ? dateFormat.format(item.cartItem.addedItem!)
                    : 'Unknown Date',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    item.cartItem.addedItem != null 
                        ? timeFormat.format(item.cartItem.addedItem!)
                        : 'Unknown Time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _removeItem(item.cartItem.id!),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Product Details Row
          Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.product.imgurl.isNotEmpty
                      ? Image.memory(
                          base64Decode(item.product.imgurl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
              ),

              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${item.product.price.toStringAsFixed(2)} each',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: \$${item.cartItem.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Controls
              Column(
                children: [
                  Row(
                    children: [
                      // Decrease quantity
                      GestureDetector(
                        onTap: () => _updateQuantity(
                          item.cartItem.id!,
                          item.cartItem.quantity - 1,
                          item.product.price,
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: item.cartItem.quantity > 1 ? Colors.black : Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: item.cartItem.quantity > 1 ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Quantity
                      Container(
                        constraints: const BoxConstraints(minWidth: 24),
                        child: Text(
                          '${item.cartItem.quantity}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Increase quantity
                      GestureDetector(
                        onTap: () => _updateQuantity(
                          item.cartItem.id!,
                          item.cartItem.quantity + 1,
                          item.product.price,
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade400,
          ],
        ),
      ),
      child: const Icon(
        Icons.shopping_bag,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
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

// Helper class to combine cart item with product details
class CartItemWithProduct {
  final CartModel cartItem;
  final ProductModel product;

  CartItemWithProduct({
    required this.cartItem,
    required this.product,
  });
}