import 'package:flutter/material.dart';

import '../model/ProductModel.dart';
import '../model/cart_model.dart';
import 'Cart/cart_controller.dart';
import 'Cart/cart_screen.dart';
import 'Home/home_controller.dart';
import 'Home/profile_avatar_widget.dart';

class AnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onLoginRequired;
  final VoidCallback? onLogoutSuccess;

  const AnimatedAppBar({
    Key? key,
    this.onLoginRequired,
    this.onLogoutSuccess,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<AnimatedAppBar> createState() => _AnimatedAppBarState();
}

class _AnimatedAppBarState extends State<AnimatedAppBar>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _avatarController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _avatarScaleAnimation;



  int _cartItemsCount = 0;
  bool _isLoading = true;
  double _totalPrice = 0.0;
  int _totalItems = 0;
  List<CartItemWithProduct> _cartItems = [];

  final CartController _cartController = CartController();
  final HomeController _homeController = HomeController();
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Avatar animation
    _avatarScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _avatarController,
      curve: Curves.bounceOut,
    ));

    // Start animations with delays
    _startAnimations();
  }

  void _startAnimations() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _avatarController.forward();
  }


  void _calculateTotals(List<CartItemWithProduct> items) {
    _totalItems = items.fold(0, (sum, item) => sum + item.cartItem.quantity);
    _totalPrice = items.fold(0.0, (sum, item) => sum + item.cartItem.totalPrice);
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

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      toolbarHeight: 80,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo and Brand Section
            Expanded(
              child: Row(
                children: [
                  // Animated Logo
                  SlideTransition(
                    position: _logoSlideAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            "logo.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Animated Text Section
                  Expanded(
                    child: SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Main Title
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Colors.black87,
                                  Colors.grey.shade700,
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'Readium',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  fontFamily: 'Montserrat',
                                  height: 1.0,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 2),
                            
                            // Subtitle
                            Text(
                              'The Ace Book Shop',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Animated Profile Avatar
            ScaleTransition(
              scale: _avatarScaleAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // optional: to ensure shadow is visible
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ProfileAvatarWidget(
                  onLoginRequired: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  onLogoutSuccess: () {
                    _loadCartItems();
                  },
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

