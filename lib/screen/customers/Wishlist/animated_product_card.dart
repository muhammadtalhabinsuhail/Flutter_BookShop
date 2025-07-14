//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:project/screen/customers/Wishlist/wishlist_controller.dart';
// import 'package:project/screen/model/ProductModel.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Home/add_to_cart_button.dart';
//
//
// class AnimatedProductCard extends StatefulWidget {
//   final ProductModel product;
//   final VoidCallback? onTap;
//   final VoidCallback? onCartUpdated;
//   final bool isSearchResult;
//
//   const AnimatedProductCard({
//     Key? key,
//     required this.product,
//     this.onTap,
//     this.onCartUpdated,
//     this.isSearchResult = false,
//   }) : super(key: key);
//
//   @override
//   State<AnimatedProductCard> createState() => _AnimatedProductCardState();
// }
//
// class _AnimatedProductCardState extends State<AnimatedProductCard>
//     with TickerProviderStateMixin {
//   final WishlistController _wishlistController = WishlistController();
//
//   late AnimationController _heartAnimationController;
//   late AnimationController _bigHeartController;
//   late Animation<double> _heartScaleAnimation;
//   late Animation<double> _bigHeartScaleAnimation;
//   late Animation<double> _bigHeartOpacityAnimation;
//
//   bool _isInWishlist = false;
//   bool _isLoading = false;
//   bool _showBigHeart = false;
//   bool _isUserLoggedIn = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _checkUserLoginStatus();
//   }
//
//   void _setupAnimations() {
//     // Heart icon animation
//     _heartAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//
//     _heartScaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.3,
//     ).animate(CurvedAnimation(
//       parent: _heartAnimationController,
//       curve: Curves.elasticOut,
//     ));
//
//     // Big heart popup animation
//     _bigHeartController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     );
//
//     _bigHeartScaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _bigHeartController,
//       curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
//     ));
//
//     _bigHeartOpacityAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: _bigHeartController,
//       curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
//     ));
//
//     // Listen for big heart animation completion
//     _bigHeartController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         setState(() {
//           _showBigHeart = false;
//         });
//         _bigHeartController.reset();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _heartAnimationController.dispose();
//     _bigHeartController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _checkUserLoginStatus() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? email = prefs.getString('email');
//       bool isLoggedIn = email != null && email.isNotEmpty;
//
//       if (mounted) {
//         setState(() {
//           _isUserLoggedIn = isLoggedIn;
//         });
//
//         // Only check wishlist status if user is logged in
//         if (isLoggedIn) {
//           _checkWishlistStatus();
//         }
//       }
//     } catch (e) {
//       print('Error checking user login status: $e');
//       if (mounted) {
//         setState(() {
//           _isUserLoggedIn = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _checkWishlistStatus() async {
//     if (widget.product.id != null && _isUserLoggedIn) {
//       try {
//         bool inWishlist = await _wishlistController.isProductInWishlist(widget.product.id!);
//         if (mounted) {
//           setState(() {
//             _isInWishlist = inWishlist;
//           });
//         }
//       } catch (e) {
//         print('Error checking wishlist status: $e');
//       }
//     }
//   }
//
//   Future<void> _handleHeartTap() async {
//     // Check if user is logged in first
//     if (!_isUserLoggedIn) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('🔐 Please login to add items to wishlist'),
//           backgroundColor: Colors.orange,
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }
//
//     if (_isLoading || widget.product.id == null) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       bool newWishlistStatus = await _wishlistController.toggleWishlistItem(widget.product.id!);
//
//       if (mounted) {
//         setState(() {
//           _isInWishlist = newWishlistStatus;
//           _isLoading = false;
//         });
//
//         // Animate heart icon
//         _heartAnimationController.forward().then((_) {
//           _heartAnimationController.reverse();
//         });
//
//         // Show big heart animation if added to wishlist
//         if (newWishlistStatus) {
//           setState(() {
//             _showBigHeart = true;
//           });
//           _bigHeartController.forward();
//
//           // Haptic feedback (uncomment if needed)
//           // HapticFeedback.lightImpact();
//         }
//
//         // Show snackbar with correct message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               newWishlistStatus
//                   ? '❤️ Added to wishlist!'
//                   : '💔 Removed from wishlist',
//             ),
//             backgroundColor: newWishlistStatus ? Colors.red : Colors.grey[700],
//             duration: const Duration(seconds: 1),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error handling heart tap: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('❌ Error updating wishlist'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: widget.isSearchResult
//                   ? Border.all(color: Colors.blue.withOpacity(0.3), width: 1)
//                   : null,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   spreadRadius: 1,
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                       color: Colors.grey[100],
//                     ),
//                     child: Stack(
//                       children: [
//                         ClipRRect(
//                           borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                           child: Image.memory(
//                             base64Decode(widget.product.imgurl),
//                             width: double.infinity,
//                             height: double.infinity,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Container(
//                                 width: double.infinity,
//                                 height: double.infinity,
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                     colors: [
//                                       Colors.orange.shade300,
//                                       Colors.orange.shade600,
//                                     ],
//                                   ),
//                                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                                 ),
//                                 child: const Icon(
//                                   FontAwesomeIcons.book,
//                                   color: Colors.white,
//                                   size: 40,
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//
//                         // Clickable Heart Icon
//                         Positioned(
//                           top: 8,
//                           right: 8,
//                           child: GestureDetector(
//                             onTap: _handleHeartTap,
//                             child: AnimatedBuilder(
//                               animation: _heartScaleAnimation,
//                               builder: (context, child) {
//                                 return Transform.scale(
//                                   scale: _heartScaleAnimation.value,
//                                   child: Container(
//                                     padding: const EdgeInsets.all(8),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white.withOpacity(0.95),
//                                       shape: BoxShape.circle,
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: _isInWishlist
//                                               ? Colors.red.withOpacity(0.3)
//                                               : Colors.grey.withOpacity(0.2),
//                                           spreadRadius: _isInWishlist ? 3 : 1,
//                                           blurRadius: _isInWishlist ? 8 : 4,
//                                         ),
//                                       ],
//                                     ),
//                                     child: _isLoading
//                                         ? SizedBox(
//                                       width: 16,
//                                       height: 16,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor: AlwaysStoppedAnimation<Color>(
//                                           _isInWishlist ? Colors.red : Colors.grey[600]!,
//                                         ),
//                                       ),
//                                     )
//                                         : Icon(
//                                       _isInWishlist ? Icons.favorite : Icons.favorite_outline,
//                                       size: 18,
//                                       color: _isUserLoggedIn
//                                           ? (_isInWishlist ? Colors.red : Colors.grey[600])
//                                           : Colors.grey[400],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//
//                         // Search Result Badge
//                         if (widget.isSearchResult)
//                           Positioned(
//                             top: 8,
//                             left: 8,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Text(
//                                 'Match',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 Expanded(
//                   flex: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.product.name ?? 'Unknown Product',
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.black,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               '\$${(widget.product.price ?? 0).toStringAsFixed(2)}',
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Container(
//                                   width: 6,
//                                   height: 6,
//                                   decoration: BoxDecoration(
//                                     color: (widget.product.quantity ?? 0) > 0 ? Colors.green : Colors.red,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Flexible(
//                                   child: Text(
//                                     (widget.product.quantity ?? 0) > 0 ? 'Available' : 'Not Available',
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       color: (widget.product.quantity ?? 0) > 0 ? Colors.green : Colors.red,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         if ((widget.product.quantity ?? 0) > 0)
//                           AddToCartButton(
//                             product: widget.product,
//                             onCartUpdated: widget.onCartUpdated,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Big Heart Animation Overlay (only show if user is logged in and adding to wishlist)
//           if (_showBigHeart && _isUserLoggedIn)
//             Positioned.fill(
//               child: AnimatedBuilder(
//                 animation: _bigHeartController,
//                 builder: (context, child) {
//                   return Opacity(
//                     opacity: _bigHeartOpacityAnimation.value,
//                     child: Center(
//                       child: Transform.scale(
//                         scale: _bigHeartScaleAnimation.value,
//                         child: Container(
//                           width: 80,
//                           height: 80,
//                           decoration: BoxDecoration(
//                             color: Colors.red.withOpacity(0.9),
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.red.withOpacity(0.3),
//                                 spreadRadius: 10,
//                                 blurRadius: 20,
//                               ),
//                             ],
//                           ),
//                           child: const Icon(
//                             Icons.favorite,
//                             color: Colors.white,
//                             size: 40,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/screen/customers/Wishlist/wishlist_controller.dart';
import 'package:project/screen/model/ProductModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home/add_to_cart_button.dart';


class AnimatedProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onCartUpdated;
  final bool isSearchResult;
  final bool isAdmin;
  final VoidCallback? onUpdateTap;

  const AnimatedProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onCartUpdated,
    this.isSearchResult = false,
    this.isAdmin = false,
    this.onUpdateTap,
  }) : super(key: key);

  @override
  State<AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<AnimatedProductCard>
    with TickerProviderStateMixin {
  final WishlistController _wishlistController = WishlistController();

  late AnimationController _heartAnimationController;
  late AnimationController _bigHeartController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _bigHeartScaleAnimation;
  late Animation<double> _bigHeartOpacityAnimation;

  bool _isInWishlist = false;
  bool _isLoading = false;
  bool _showBigHeart = false;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkUserLoginStatus();
  }

  void _setupAnimations() {
    // Heart icon animation
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heartScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));

    // Big heart popup animation
    _bigHeartController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _bigHeartScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bigHeartController,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _bigHeartOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _bigHeartController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    // Listen for big heart animation completion
    _bigHeartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showBigHeart = false;
        });
        _bigHeartController.reset();
      }
    });
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _bigHeartController.dispose();
    super.dispose();
  }

  Future<void> _checkUserLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');
      bool isLoggedIn = email != null && email.isNotEmpty;

      if (mounted) {
        setState(() {
          _isUserLoggedIn = isLoggedIn;
        });

        // Only check wishlist status if user is logged in
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
    // Check if user is logged in first
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

        // Animate heart icon
        _heartAnimationController.forward().then((_) {
          _heartAnimationController.reverse();
        });

        // Show big heart animation if added to wishlist
        if (newWishlistStatus) {
          setState(() {
            _showBigHeart = true;
          });
          _bigHeartController.forward();

          // Haptic feedback (uncomment if needed)
          // HapticFeedback.lightImpact();
        }

        // Show snackbar with correct message
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
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: widget.isSearchResult
                  ? Border.all(color: Colors.blue.withOpacity(0.3), width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      color: Colors.grey[100],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.memory(
                            base64Decode(widget.product.imgurl),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange.shade300,
                                      Colors.orange.shade600,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.book,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),

                        // Clickable Heart Icon
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _handleHeartTap,
                            child: AnimatedBuilder(
                              animation: _heartScaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _heartScaleAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _isInWishlist
                                              ? Colors.red.withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.2),
                                          spreadRadius: _isInWishlist ? 3 : 1,
                                          blurRadius: _isInWishlist ? 8 : 4,
                                        ),
                                      ],
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          _isInWishlist ? Colors.red : Colors.grey[600]!,
                                        ),
                                      ),
                                    )
                                        : Icon(
                                      _isInWishlist ? Icons.favorite : Icons.favorite_outline,
                                      size: 18,
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

                        // Search Result Badge
                        if (widget.isSearchResult)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Match',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        // Admin Update Icon (Top Left)
                        if (widget.isAdmin && widget.onUpdateTap != null)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: GestureDetector(
                              onTap: widget.onUpdateTap,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name ?? 'Unknown Product',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${(widget.product.price ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: (widget.product.quantity ?? 0) > 0 ? Colors.green : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    (widget.product.quantity ?? 0) > 0 ? 'Available' : 'Not Available',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: (widget.product.quantity ?? 0) > 0 ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if ((widget.product.quantity ?? 0) > 0)
                          AddToCartButton(
                            product: widget.product,
                            onCartUpdated: widget.onCartUpdated,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Big Heart Animation Overlay (only show if user is logged in and adding to wishlist)
          if (_showBigHeart && _isUserLoggedIn)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bigHeartController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _bigHeartOpacityAnimation.value,
                    child: Center(
                      child: Transform.scale(
                        scale: _bigHeartScaleAnimation.value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                spreadRadius: 10,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
