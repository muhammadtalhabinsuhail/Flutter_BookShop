import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/screen/model/ProductModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Wishlist/wishlist_controller.dart';
import 'add_to_cart_button.dart';

class ProductDetailsSheet extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onCartUpdated;

  const ProductDetailsSheet({
    Key? key,
    required this.product,
    this.onCartUpdated,
  }) : super(key: key);

  @override
  State<ProductDetailsSheet> createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<ProductDetailsSheet>
    with TickerProviderStateMixin {
  final WishlistController _wishlistController = WishlistController();
  
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  
  bool _isInWishlist = false;
  bool _isLoading = false;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkUserLoginStatus();
  }

  void _setupAnimations() {
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _heartScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkUserLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('Email');
      bool isLoggedIn = email != null && email.isNotEmpty;
      
      if (mounted) {
        setState(() {
          _isUserLoggedIn = isLoggedIn;
        });
        
        if (isLoggedIn) {
          _checkWishlistStatus();
        }
      }
    } catch (e) {
      print('Error checking user login status: $e');
      if (mounted) {
        setState(() {
          _isUserLoggedIn = false;
        });
      }
    }
  }

  Future<void> _checkWishlistStatus() async {
    if (widget.product.id != null && _isUserLoggedIn) {
      try {
        bool inWishlist = await _wishlistController.isProductInWishlist(widget.product.id!);
        if (mounted) {
          setState(() {
            _isInWishlist = inWishlist;
          });
        }
      } catch (e) {
        print('Error checking wishlist status: $e');
      }
    }
  }

  Future<void> _handleHeartTap() async {
    if (!_isUserLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔐 Please login to add items to wishlist'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isLoading || widget.product.id == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool newWishlistStatus = await _wishlistController.toggleWishlistItem(widget.product.id!);
      
      if (mounted) {
        setState(() {
          _isInWishlist = newWishlistStatus;
          _isLoading = false;
        });

        _heartAnimationController.forward().then((_) {
          _heartAnimationController.reverse();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newWishlistStatus 
                  ? '❤️ Added to wishlist!' 
                  : '💔 Removed from wishlist',
            ),
            backgroundColor: newWishlistStatus ? Colors.red : Colors.grey[700],
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error handling heart tap: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error updating wishlist'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image with Heart Icon
                  Stack(
                    children: [
                      Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[100],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            base64Decode(widget.product.imgurl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.shade300,
                                      Colors.orange.shade600,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.laptop_mac,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Heart Icon
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: _handleHeartTap,
                          child: AnimatedBuilder(
                            animation: _heartScaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _heartScaleAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _isInWishlist 
                                            ? Colors.red.withOpacity(0.3)
                                            : Colors.grey.withOpacity(0.2),
                                        spreadRadius: _isInWishlist ? 4 : 2,
                                        blurRadius: _isInWishlist ? 10 : 6,
                                      ),
                                    ],
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              _isInWishlist ? Colors.red : Colors.grey[600]!,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          _isInWishlist ? Icons.favorite : Icons.favorite_outline,
                                          size: 24,
                                          color: _isUserLoggedIn 
                                              ? (_isInWishlist ? Colors.red : Colors.grey[600])
                                              : Colors.grey[400],
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Product Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name ?? 'Unknown Product',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        '\$${(widget.product.price ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: ((widget.product.quantity ?? 0) > 0) ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ((widget.product.quantity ?? 0) > 0)
                            ? 'Available (${widget.product.quantity} left)'
                            : 'Not Available',
                        style: TextStyle(
                          fontSize: 16,
                          color: ((widget.product.quantity ?? 0) > 0) ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description ?? 'No description available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if ((widget.product.quantity ?? 0) > 0)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: AddToCartButton(
                        product: widget.product,
                        onCartUpdated: () {
                          if (widget.onCartUpdated != null) {
                            widget.onCartUpdated!();
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}