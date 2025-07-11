import 'package:flutter/material.dart';
import 'package:project/screen/customers/Cart/cart_screen.dart';
import 'package:project/screen/customers/CustomerProfileUpdate/customer_profile_update_screen.dart';
import 'package:project/screen/customers/Home/home_view.dart';
import 'package:project/screen/customers/OrdersTracking/my_orders_screen.dart';
import 'package:project/screen/customers/Trends/trends_screen.dart';
import 'package:project/screen/customers/Wishlist/wishlist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'Login/LoginScreen.dart';

class EnhancedBottomNavigation extends StatefulWidget {
  final int currentIndex;

  const EnhancedBottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _EnhancedBottomNavigationState createState() => _EnhancedBottomNavigationState();
}

class _EnhancedBottomNavigationState extends State<EnhancedBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _hoverAnimation;

  int _cartItemsCount = 0;
  int _wishlistCount = 0;
  int _ordersCount = 0;
  String? _currentUserId;
  int _hoveredIndex = -1;
  bool isLoggedIn = false;


  // Real-time listeners
  StreamSubscription<QuerySnapshot>? _cartListener;
  StreamSubscription<QuerySnapshot>? _wishlistListener;
  StreamSubscription<QuerySnapshot>? _ordersListener;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeUser();
    checkLoginStatus();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }


  Future<bool> isUserLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');
      return userEmail != null;
    } catch (e) {
      return false;
    }
  }


  void checkLoginStatus() async {
    isLoggedIn = await isUserLoggedIn();
  }




  Future<void> _initializeUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');

      if (userEmail != null) {
        QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('User')
            .where('Email', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          setState(() {
            _currentUserId = userQuery.docs.first.id;
          });
          _setupRealTimeListeners();
        }
      }
    } catch (e) {
      print('Error initializing user: $e');
    }
  }

  void _setupRealTimeListeners() {
    if (_currentUserId == null) return;

    // Real-time Cart listener
    _cartListener = FirebaseFirestore.instance
        .collection('Cart')
        .where('UserId', isEqualTo: _currentUserId)
        .where('isCheckedOut', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _cartItemsCount = snapshot.docs.length;
        });
        print('Cart count updated: $_cartItemsCount'); // Debug log
      }
    }, onError: (error) {
      print('Error listening to cart changes: $error');
    });

    // Real-time Wishlist listener
    _wishlistListener = FirebaseFirestore.instance
        .collection('Wishlist')
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _wishlistCount = snapshot.docs.length;
        });
        print('Wishlist count updated: $_wishlistCount'); // Debug log
      }
    }, onError: (error) {
      print('Error listening to wishlist changes: $error');
      if (mounted) {
        setState(() {
          _wishlistCount = 0;
        });
      }
    });

    // Real-time Orders listener
    _ordersListener = FirebaseFirestore.instance
        .collection('Orders')
        .where('userId', isEqualTo: _currentUserId)
        .where('orderStatus', whereNotIn: ['Delivered', 'Cancelled'])
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _ordersCount = snapshot.docs.length;
        });
        print('Orders count updated: $_ordersCount'); // Debug log
      }
    }, onError: (error) {
      print('Error listening to orders changes: $error');
      if (mounted) {
        setState(() {
          _ordersCount = 0;
        });
      }
    });
  }

  // Method to manually refresh counts (can be called from other screens)
  Future<void> refreshCounts() async {
    if (_currentUserId == null) return;

    try {
      // Get fresh counts from database
      final cartQuery = await FirebaseFirestore.instance
          .collection('Cart')
          .where('UserId', isEqualTo: _currentUserId)
          .where('isCheckedOut', isEqualTo: false)
          .get();

      final wishlistQuery = await FirebaseFirestore.instance
          .collection('Wishlist')
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final ordersQuery = await FirebaseFirestore.instance
          .collection('Orders')
          .where('userId', isEqualTo: _currentUserId)
          .where('orderStatus', whereNotIn: ['Delivered', 'Cancelled'])
          .get();

      if (mounted) {
        setState(() {
          _cartItemsCount = cartQuery.docs.length;
          _wishlistCount = wishlistQuery.docs.length;
          _ordersCount = ordersQuery.docs.length;
        });
      }
    } catch (e) {
      print('Error refreshing counts: $e');
    }
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    Widget targetScreen;
    Future<bool> islogined;
    switch (index) {
      case 0:
        targetScreen = Home();
        break;
      case 1:
        targetScreen = TrendsScreen();
        break;
      case 2:
        targetScreen = CartScreen();
        break;
      case 3:
        targetScreen = MyOrdersScreen();
        break;
      case 4:
        targetScreen = WishlistScreen();
        break;
      case 5:



           if(isLoggedIn == true) {
          targetScreen = CustomerProfileUpdateScreen();
        }else {
          // Optionally redirect to login screen
          targetScreen = LoginScreen();  // Replace with your login screen
        }
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  void _onHover(int index, bool isHovering) {
    setState(() {
      _hoveredIndex = isHovering ? index : -1;
    });

    if (isHovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Responsive calculations
    final containerHeight = screenHeight * 0.08 + bottomPadding;
    final iconSize = screenWidth * 0.055;
    final fontSize = screenWidth * 0.024;
    final horizontalPadding = screenWidth * 0.02;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: Offset(0, -8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.008,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', iconSize, fontSize),
              _buildNavItem(1, Icons.local_fire_department_outlined, Icons.local_fire_department, 'Trends', iconSize, fontSize),
              _buildNavItem(2, Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart', iconSize, fontSize, badgeCount: _cartItemsCount, badgeColor: Colors.red),
              _buildNavItem(3, Icons.shopping_bag_outlined, Icons.shopping_bag, 'Orders', iconSize, fontSize, badgeCount: _ordersCount, badgeColor: Colors.orange),
              _buildNavItem(4, Icons.favorite_outline, Icons.favorite, 'Wishlist', iconSize, fontSize, badgeCount: _wishlistCount, badgeColor: Colors.pink),
              _buildNavItem(5, Icons.person_outline, Icons.person, 'Profile', iconSize, fontSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index,
      IconData icon,
      IconData activeIcon,
      String label,
      double iconSize,
      double fontSize, {
        int? badgeCount,
        Color? badgeColor,
      }) {
    final bool isActive = widget.currentIndex == index;
    final bool isHovered = _hoveredIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTap(index),
        child: MouseRegion(
          onEnter: (_) => _onHover(index, true),
          onExit: (_) => _onHover(index, false),
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleAnimation, _hoverAnimation]),
            builder: (context, child) {
              final scale = isActive ? _scaleAnimation.value :
              isHovered ? 1.05 : 1.0;

              return Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.015,
                    vertical: screenWidth * 0.02,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.005),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.black.withOpacity(0.08)
                        : isHovered
                        ? Colors.grey.withOpacity(0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    border: isActive
                        ? Border.all(color: Colors.black.withOpacity(0.1), width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with Badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              isActive ? activeIcon : icon,
                              key: ValueKey('${isActive}_$index'),
                              color: isActive
                                  ? Colors.black
                                  : isHovered
                                  ? Colors.black.withOpacity(0.8)
                                  : Colors.grey[600],
                              size: iconSize,
                            ),
                          ),
                          if (badgeCount != null && badgeCount > 0)
                            Positioned(
                              right: -screenWidth * 0.015,
                              top: -screenWidth * 0.01,
                              child: _buildBadge(badgeCount, badgeColor ?? Colors.red, screenWidth),
                            ),
                        ],
                      ),

                      SizedBox(height: screenWidth * 0.008),

                      // Label
                      AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive
                              ? Colors.black
                              : isHovered
                              ? Colors.black.withOpacity(0.8)
                              : Colors.grey[600],
                          letterSpacing: 0.2,
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(int count, Color color, double screenWidth) {
    final badgeSize = screenWidth * 0.045;
    final fontSize = screenWidth * 0.022;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.008),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(badgeSize / 2),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            constraints: BoxConstraints(
              minWidth: badgeSize,
              minHeight: badgeSize,
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Cancel all stream subscriptions
    _cartListener?.cancel();
    _wishlistListener?.cancel();
    _ordersListener?.cancel();

    // Dispose animation controllers
    _animationController.dispose();
    _hoverController.dispose();
    super.dispose();
  }
}