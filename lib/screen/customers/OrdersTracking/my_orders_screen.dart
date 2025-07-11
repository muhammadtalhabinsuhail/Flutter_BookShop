//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:project/screen/model/orders_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../model/ProductModel.dart';
// import '../../model/cart_model.dart';
// import '../Cart/cart_controller.dart';
// import '../Cart/cart_screen.dart';
// import '../CheckOut/checkout_controller.dart';
// import '../Home/home_controller.dart';
// import '../Home/profile_avatar_widget.dart';
// import '../base_customer_screen.dart';
// import 'order_tracking_screen.dart';
//
// class MyOrdersScreen extends StatefulWidget {
//   @override
//   _MyOrdersScreenState createState() => _MyOrdersScreenState();
// }
//
// class _MyOrdersScreenState extends State<MyOrdersScreen> with TickerProviderStateMixin {
//   List<OrdersModel> _orders = [];
//   List<OrdersModel> _filteredOrders = [];
//   bool _isLoading = true;
//   String _selectedFilter = 'All';
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late TabController _tabController;
//
//   final List<String> _filterOptions = ['All', 'Pending', 'Order Placed', 'Approved', 'Delivered'];
//   final List<String> _tabLabels = ['All', 'Delivered'];
//
//   late AnimationController _logoController;
//   late AnimationController _textController;
//   late AnimationController _avatarController;
//   late AnimationController _cardAnimationController;
//   late AnimationController _statsAnimationController;
//
//   late Animation<double> _logoScaleAnimation;
//   late Animation<Offset> _logoSlideAnimation;
//   late Animation<double> _textFadeAnimation;
//   late Animation<Offset> _textSlideAnimation;
//   late Animation<double> _avatarScaleAnimation;
//   late Animation<double> _cardSlideAnimation;
//   late Animation<double> _statsScaleAnimation;
//   Map<String, List<OrdersModel>> groupedOrders = {};
//
//
//
//
//
//   int _cartItemsCount = 0;
//   double _totalPrice = 0.0;
//   int _totalItems = 0;
//   List<CartItemWithProduct> _cartItems = [];
//
//   final CartController _cartController = CartController();
//   final HomeController _homeController = HomeController();
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _loadOrders();
//   }
//
//   void _initializeAnimations() {
//     // Main animation controller
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 1200),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//
//     // Tab controller
//     _tabController = TabController(length: _tabLabels.length, vsync: this);
//
//     // AppBar animations
//     _logoController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//
//     _textController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
//
//     _avatarController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     // Card animation controller
//     _cardAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     // Stats animation controller
//     _statsAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//
//     // Logo animations
//     _logoScaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _logoController,
//       curve: Curves.elasticOut,
//     ));
//
//     _logoSlideAnimation = Tween<Offset>(
//       begin: const Offset(-1.0, 0.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _logoController,
//       curve: Curves.easeOutCubic,
//     ));
//
//     // Text animations
//     _textFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _textController,
//       curve: Curves.easeInOut,
//     ));
//
//     _textSlideAnimation = Tween<Offset>(
//       begin: const Offset(0.0, -0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _textController,
//       curve: Curves.easeOutCubic,
//     ));
//
//     // Avatar animation
//     _avatarScaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _avatarController,
//       curve: Curves.bounceOut,
//     ));
//
//     // Card animation
//     _cardSlideAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _cardAnimationController,
//       curve: Curves.easeOutCubic,
//     ));
//
//     // Stats animation
//     _statsScaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _statsAnimationController,
//       curve: Curves.elasticOut,
//     ));
//
//     // Start animations with delays
//     _startAnimations();
//   }
//
//   void _startAnimations() async {
//     _logoController.forward();
//     await Future.delayed(const Duration(milliseconds: 200));
//     _textController.forward();
//     await Future.delayed(const Duration(milliseconds: 300));
//     _avatarController.forward();
//     await Future.delayed(const Duration(milliseconds: 400));
//     _statsAnimationController.forward();
//     await Future.delayed(const Duration(milliseconds: 200));
//     _cardAnimationController.forward();
//   }
//
//   Future<void> _loadOrders() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? userEmail = prefs.getString('email');
//
//       if (userEmail != null) {
//         String? userId = await CheckoutController.getUserIdByEmail(userEmail);
//
//         if (userId != null) {
//           // ✅ Fetch ALL orders of the user
//           QuerySnapshot userOrdersSnapshot = await FirebaseFirestore.instance
//               .collection('Orders')
//               .where('userId', isEqualTo: userId)
//               .orderBy('orderDate', descending: true)
//               .get();
//
//           if (userOrdersSnapshot.docs.isNotEmpty) {
//             // ✅ Convert to model list
//             List<OrdersModel> allOrders = OrdersModel.fromQuerySnapshot(userOrdersSnapshot);
//
//             // ✅ Group orders by orderId
//
//
//             for (var order in allOrders) {
//               if (!groupedOrders.containsKey(order.orderId)) {
//                 groupedOrders[order.orderId] = [];
//               }
//               groupedOrders[order.orderId]!.add(order);
//             }
//
//             // ✅ Summarize each group into one order card
//             _orders = groupedOrders.entries.map((entry) {
//               final orderGroup = entry.value;
//               final firstOrder = orderGroup.first;
//
//               double total = orderGroup.fold(0, (sum, o) => sum + o.totalAmount);
//
//               return OrdersModel(
//                 orderId: firstOrder.orderId,
//                 userId: firstOrder.userId,
//                 productId: firstOrder.productId,
//                 cartId: firstOrder.cartId,
//                 totalAmount: total,
//                 paymentMethod: firstOrder.paymentMethod,
//                 orderStatus: firstOrder.orderStatus,
//                 orderDate: firstOrder.orderDate,
//                 notes: firstOrder.notes,
//                 paymentStatus: firstOrder.paymentStatus,
//               );
//             }).toList();
//
//             _applyFilter(); // Apply your filter if needed (e.g. "Delivered", etc.)
//             _animationController.forward(); // Trigger UI animation
//
//           } else {
//             // No orders found
//             _orders = [];
//           }
//         }
//       }
//     } catch (e) {
//       print('Error loading orders: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error loading orders: $e'),
//           backgroundColor: Colors.grey[800],
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//
//
//
//
//
//
//
//   void _applyFilter() {
//     if (_selectedFilter == 'All') {
//       _filteredOrders = List.from(_orders);
//     } else if (_selectedFilter == 'Delivered') {
//       // Filter for delivered orders (case-insensitive)
//       _filteredOrders = _orders
//           .where((order) => order.orderStatus.toLowerCase() == 'delivered')
//           .toList();
//     } else {
//       // For other filters, match exactly
//       _filteredOrders = _orders
//           .where((order) => order.orderStatus == _selectedFilter)
//           .toList();
//     }
//     setState(() {});
//   }
//
//   void _calculateTotals(List<CartItemWithProduct> items) {
//     _totalItems = items.fold(0, (sum, item) => sum + item.cartItem.quantity);
//     _totalPrice = items.fold(0.0, (sum, item) => sum + item.cartItem.totalPrice);
//   }
//
//   Future<void> _loadCartItems() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       List<CartModel> cartItems = await _cartController.getCartItems();
//       List<CartItemWithProduct> itemsWithProducts = [];
//
//       for (CartModel cartItem in cartItems) {
//         ProductModel? product = await _homeController.getProductById(cartItem.productId);
//         if (product != null) {
//           itemsWithProducts.add(CartItemWithProduct(
//             cartItem: cartItem,
//             product: product,
//           ));
//         }
//       }
//
//       _calculateTotals(itemsWithProducts);
//
//       setState(() {
//         _cartItems = itemsWithProducts;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading cart items: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//
//
//
//
//
//
//   List<OrdersModel> orderItems = [];
//   bool isLoading = true;
//
//
//   Future<void> _loadOrderItemsByOrderId(String id) async {
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('Orders')
//           .where('orderId', isEqualTo: id)
//           .get();
//
//       setState(() {
//         orderItems = snapshot.docs
//             .map((doc) => OrdersModel.fromMap(doc.data() as Map<String, dynamic>))
//             .toList();
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching order items: $e');
//       setState(() => isLoading = false);
//     }
//   }
//
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           _buildStatsHeader(),
//           Expanded(
//             child: _isLoading
//                 ? _buildLoadingState()
//                 : _buildOrdersList(),
//           ),
//         ],
//       ),
//       bottomNavigationBar: EnhancedBottomNavigation(currentIndex: 3),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       shadowColor: Colors.black.withOpacity(0.1),
//       toolbarHeight: 80,
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.white,
//               Colors.grey.shade50,
//             ],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//       ),
//       title: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Logo and Brand Section
//             Expanded(
//               child: Row(
//                 children: [
//                   // Animated Logo
//                   SlideTransition(
//                     position: _logoSlideAnimation,
//                     child: ScaleTransition(
//                       scale: _logoScaleAnimation,
//                       child: Container(
//                         width: 45,
//                         height: 45,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 8,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.asset(
//                             "logo.png",
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(width: 12),
//
//                   // Animated Text Section
//                   Expanded(
//                     child: SlideTransition(
//                       position: _textSlideAnimation,
//                       child: FadeTransition(
//                         opacity: _textFadeAnimation,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             // Main Title
//                             ShaderMask(
//                               shaderCallback: (bounds) => LinearGradient(
//                                 colors: [
//                                   Colors.black87,
//                                   Colors.grey.shade700,
//                                 ],
//                               ).createShader(bounds),
//                               child: const Text(
//                                 'Readium',
//                                 style: TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.w800,
//                                   color: Colors.white,
//                                   letterSpacing: 1.2,
//                                   fontFamily: 'Montserrat',
//                                   height: 1.0,
//                                 ),
//                               ),
//                             ),
//
//                             const SizedBox(height: 2),
//
//                             // Subtitle
//                             Text(
//                               'The Ace Book Shop',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey.shade600,
//                                 fontWeight: FontWeight.w500,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Animated Profile Avatar
//             ScaleTransition(
//               scale: _avatarScaleAnimation,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(25),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: ProfileAvatarWidget(
//                   onLoginRequired: () {
//                     // Handle login navigation
//                   },
//                   onLogoutSuccess: () {
//                     _loadCartItems();
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottom: TabBar(
//         controller: _tabController,
//         indicatorColor: Colors.grey[800],
//         indicatorWeight: 3,
//         labelColor: Colors.grey[800],
//         unselectedLabelColor: Colors.grey[500],
//         labelStyle: TextStyle(fontWeight: FontWeight.w600),
//         unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
//         onTap: (index) {
//           // 🔥 FIXED: Correct tab index mapping
//           switch (index) {
//             case 0:
//               _selectedFilter = 'All';
//               break;
//             case 1:
//               _selectedFilter = 'Delivered'; // ✅ Fixed: was 'Active' before
//               break;
//           }
//           _applyFilter();
//           print('Selected filter: $_selectedFilter'); // Debug print
//           print('Filtered orders count: ${_filteredOrders.length}'); // Debug print
//         },
//         tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
//       ),
//     );
//   }
//
//   Widget _buildStatsHeader() {
//     return ScaleTransition(
//       scale: _statsScaleAnimation,
//       child: Container(
//         margin: EdgeInsets.all(16),
//         padding: EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.black!, Colors.grey[700]!],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.grey, width: 1),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 15,
//               offset: Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: _buildStatItem(
//                 'Total Orders',
//                 _orders.length.toString(),
//                 Icons.shopping_bag_outlined,
//               ),
//             ),
//             Container(
//               width: 1,
//               height: 50,
//               color: Colors.grey[400]!.withOpacity(0.6),
//             ),
//             Expanded(
//               child: _buildStatItem(
//                 'Active',
//                 _orders.where((o) => o.orderStatus.toLowerCase() != 'delivered').length.toString(),
//                 Icons.local_shipping_outlined,
//               ),
//             ),
//             Container(
//               width: 1,
//               height: 50,
//               color: Colors.grey[400]!.withOpacity(0.6),
//             ),
//             Expanded(
//               child: _buildStatItem(
//                 'Delivered',
//                 _orders.where((o) => o.orderStatus.toLowerCase() == 'delivered').length.toString(),
//                 Icons.check_circle_outline,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatItem(String label, String value, IconData icon) {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 1200),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, animationValue, child) {
//         return Transform.scale(
//           scale: 0.8 + (0.2 * animationValue),
//           child: Column(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.white.withOpacity(0.3)),
//                 ),
//                 child: Icon(icon, color: Colors.white, size: 28),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: Colors.grey[200],
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[800]!),
//               strokeWidth: 3,
//             ),
//           ),
//           SizedBox(height: 24),
//           Text(
//             'Loading your orders...',
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrdersList() {
//     if (_filteredOrders.isEmpty) return _buildEmptyState();
//
//
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: _filteredOrders.length,
//         itemBuilder: (context, index) {
//           final order = _filteredOrders[index];
//           return _buildOrderCard(order, index); // 🟢 Already totals are ready
//         },
//       ),
//     );
//   }
//
//
//
//
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 140,
//             height: 140,
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey[300]!, width: 2),
//             ),
//             child: Icon(
//               Icons.shopping_bag_outlined,
//               size: 70,
//               color: Colors.grey[500],
//             ),
//           ),
//           SizedBox(height: 32),
//           Text(
//             _selectedFilter == 'Delivered' ? 'No Delivered Orders' : 'No Orders Yet',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           SizedBox(height: 12),
//           Text(
//             _selectedFilter == 'Delivered'
//                 ? 'You don\'t have any delivered orders yet'
//                 : 'Start shopping to see your orders here',
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 16,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           SizedBox(height: 40),
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.grey[800]!, Colors.black],
//               ),
//               borderRadius: BorderRadius.circular(30),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.pushReplacementNamed(context, '/home');
//               },
//               icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
//               label: Text(
//                 'Start Shopping',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 shadowColor: Colors.transparent,
//                 padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrderCard(OrdersModel order, int index) {
//
//     _loadOrderItemsByOrderId(order.orderId);
//
//
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 800 + (index * 150)),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, 30 * (1 - value)),
//           child: Opacity(
//             opacity: value,
//             child: Container(
//               margin: EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.grey[200]!, width: 1),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 15,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     PageRouteBuilder(
//                       pageBuilder: (context, animation, secondaryAnimation) =>
//                           OrderTrackingScreen(order: orderItems),
//                       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                         return SlideTransition(
//                           position: animation.drive(
//                             Tween(begin: Offset(1.0, 0.0), end: Offset.zero)
//                                 .chain(CurveTween(curve: Curves.easeInOut)),
//                           ),
//                           child: child,
//                         );
//                       },
//                     ),
//                   );
//                 },
//                 borderRadius: BorderRadius.circular(20),
//                 child: Padding(
//                   padding: EdgeInsets.all(24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Flexible(
//                             child: Container(
//                               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[100],
//                                 borderRadius: BorderRadius.circular(25),
//                                 border: Border.all(color: Colors.grey[300]!),
//                               ),
//                               child: Tooltip(
//                                 message: 'Order #${order.orderId}',
//                                 padding: EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black87,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 textStyle: TextStyle(color: Colors.white, fontSize: 12),
//                                 waitDuration: Duration(milliseconds: 500), // hover wait
//                                 child: Text(
//                                   'Order #${order.orderId}',
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   softWrap: false,
//                                   style: TextStyle(
//                                     color: Colors.grey[800],
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 10,
//                                   ),
//                                 ),
//                               ),
//
//                             ),
//                           ),
//
//
//                           Spacer(),
//                           Flexible(child: _buildAnimatedStatusChip(order.orderStatus)),
//                         ],
//                       ),
//
//                       SizedBox(height: 20),
//                       Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[100],
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[700]),
//                           ),
//                           SizedBox(width: 12),
//                           Text(
//                             _formatDate(order.orderDate),
//                             style: TextStyle(
//                               color: Colors.grey[700],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           Spacer(),
//                           Container(
//                             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[800],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               '\$${order.totalAmount.toStringAsFixed(2)}',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 20),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Material(
//                               color: Colors.white,
//                               child: InkWell(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => OrderTrackingScreen(order: orderItems),
//                                     ),
//                                   );
//                                 },
//                                 borderRadius: BorderRadius.circular(12),
//                                 splashColor: Colors.white,
//                                 highlightColor: Colors.white,
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(color: Color(0xFFF97316), width: 0.5),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.track_changes_outlined,
//                                         size: 20,
//                                         color: Color(0xFFF97316),
//                                       ),
//                                       SizedBox(width: 8),
//                                       Text(
//                                         'Track Order',
//                                         style: TextStyle(
//                                           color: Color(0xFFF97316),
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 16),
//                           Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Colors.grey[800]!, Colors.black],
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   blurRadius: 8,
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: IconButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => OrderTrackingScreen(order: orderItems),
//                                   ),
//                                 );
//                               },
//                               icon: Icon(Icons.arrow_forward_outlined, color: Colors.white, size: 22),
//                               tooltip: 'View Details',
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//
//
//
//     );
//   }
//
//
//
//
//
//
//
//   Widget _buildAnimatedStatusChip(String status) {
//     Color borderColor;
//     IconData icon;
//
//     switch (status.toLowerCase()) {
//       case 'pending':
//         borderColor = Colors.orange[600]!;
//         icon = Icons.pending_outlined;
//         break;
//       case 'order placed':
//         borderColor = Colors.orange!;
//         icon = Icons.shopping_bag_outlined;
//         break;
//       case 'approved':
//         borderColor = Colors.green[600]!;
//         icon = Icons.check_circle_outline;
//         break;
//       case 'processing':
//         borderColor = Colors.purple[600]!;
//         icon = Icons.settings_outlined;
//         break;
//       case 'shipped':
//         borderColor = Colors.indigo[600]!;
//         icon = Icons.local_shipping_outlined;
//         break;
//       case 'out for delivery':
//         borderColor = Colors.teal[600]!;
//         icon = Icons.delivery_dining_outlined;
//         break;
//       case 'delivered':
//         borderColor = Colors.green[700]!;
//         icon = Icons.check_circle_outline;
//         break;
//       default:
//         borderColor = Colors.grey[600]!;
//         icon = Icons.help_outline;
//     }
//
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 1200),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.scale(
//           scale: 0.8 + (0.2 * value),
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.transparent,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: borderColor, width: 1.5),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(icon, size: 14, color: borderColor),
//                 SizedBox(width: 6),
//                 Flexible(
//                   child: Text(
//                     status,
//                     style: TextStyle(
//                       color: borderColor,
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _tabController.dispose();
//     _logoController.dispose();
//     _textController.dispose();
//     _avatarController.dispose();
//     _cardAnimationController.dispose();
//     _statsAnimationController.dispose();
//     super.dispose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/orders_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/ProductModel.dart';
import '../../model/cart_model.dart';
import '../Cart/cart_controller.dart';
import '../Cart/cart_screen.dart';
import '../CheckOut/checkout_controller.dart';
import '../Home/home_controller.dart';
import '../Home/profile_avatar_widget.dart';
import '../base_customer_screen.dart';
import 'order_tracking_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with TickerProviderStateMixin {
  List<OrdersModel> _orders = [];
  List<OrdersModel> _filteredOrders = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  final List<String> _filterOptions = ['All', 'Pending', 'Order Placed', 'Approved', 'Delivered'];
  final List<String> _tabLabels = ['All', 'Delivered'];

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _avatarController;
  late AnimationController _cardAnimationController;
  late AnimationController _statsAnimationController;

  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _statsScaleAnimation;
  Map<String, List<OrdersModel>> groupedOrders = {};

  int _cartItemsCount = 0;
  double _totalPrice = 0.0;
  int _totalItems = 0;
  List<CartItemWithProduct> _cartItems = [];

  final CartController _cartController = CartController();
  final HomeController _homeController = HomeController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadOrders();
  }

  void _initializeAnimations() {
    // Main animation controller
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Tab controller
    _tabController = TabController(length: _tabLabels.length, vsync: this);

    // AppBar animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Card animation controller
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Stats animation controller
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    // Card animation
    _cardSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Stats animation
    _statsScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.elasticOut,
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
    await Future.delayed(const Duration(milliseconds: 400));
    _statsAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardAnimationController.forward();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');

      if (userEmail != null) {
        String? userId = await CheckoutController.getUserIdByEmail(userEmail);

        if (userId != null) {
          // ✅ Fetch ALL orders of the user
          QuerySnapshot userOrdersSnapshot = await FirebaseFirestore.instance
              .collection('Orders')
              .where('userId', isEqualTo: userId)
              .orderBy('orderDate', descending: true)
              .get();

          if (userOrdersSnapshot.docs.isNotEmpty) {
            // ✅ Convert to model list
            List<OrdersModel> allOrders = OrdersModel.fromQuerySnapshot(userOrdersSnapshot);

            // ✅ Group orders by orderId
            for (var order in allOrders) {
              if (!groupedOrders.containsKey(order.orderId)) {
                groupedOrders[order.orderId] = [];
              }
              groupedOrders[order.orderId]!.add(order);
            }

            // ✅ Summarize each group into one order card
            _orders = groupedOrders.entries.map((entry) {
              final orderGroup = entry.value;
              final firstOrder = orderGroup.first;

              double total = orderGroup.fold(0, (sum, o) => sum + o.totalAmount);

              return OrdersModel(
                orderId: firstOrder.orderId,
                userId: firstOrder.userId,
                productId: firstOrder.productId,
                cartId: firstOrder.cartId,
                totalAmount: total,
                paymentMethod: firstOrder.paymentMethod,
                orderStatus: firstOrder.orderStatus,
                orderDate: firstOrder.orderDate,
                notes: firstOrder.notes,
                paymentStatus: firstOrder.paymentStatus,
              );
            }).toList();

            _applyFilter(); // Apply your filter if needed (e.g. "Delivered", etc.)
            _animationController.forward(); // Trigger UI animation

          } else {
            // No orders found
            _orders = [];
          }
        }
      }
    } catch (e) {
      print('Error loading orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading orders: $e'),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      _filteredOrders = List.from(_orders);
    } else if (_selectedFilter == 'Delivered') {
      // Filter for delivered orders (case-insensitive)
      _filteredOrders = _orders
          .where((order) => order.orderStatus.toLowerCase() == 'delivered')
          .toList();
    } else {
      // For other filters, match exactly
      _filteredOrders = _orders
          .where((order) => order.orderStatus == _selectedFilter)
          .toList();
    }
    setState(() {});
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

  // ✅ FIXED: This function now returns the order items instead of setting a global variable
  Future<List<OrdersModel>> _loadOrderItemsByOrderId(String orderId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('orderId', isEqualTo: orderId)
          .get();

      return snapshot.docs
          .map((doc) => OrdersModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching order items: $e');
      return [];
    }
  }

  // ✅ FIXED: New method to handle navigation with proper order loading
  Future<void> _navigateToOrderTracking(String orderId) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),

              ],
            ),
          ),
        );
      },
    );

    try {
      // Load the specific order items
      List<OrdersModel> orderItems = await _loadOrderItemsByOrderId(orderId);

      // Close loading dialog
      Navigator.of(context).pop();

      if (orderItems.isNotEmpty) {
        // Navigate with the correct order items
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                OrderTrackingScreen(order: orderItems),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: Offset(1.0, 0.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No order details found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading order details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsHeader(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _buildOrdersList(),
          ),
        ],
      ),
      bottomNavigationBar: EnhancedBottomNavigation(currentIndex: 3),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
                          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
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
                  color: Colors.white,
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
                    // Handle login navigation
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
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.grey[800],
        indicatorWeight: 3,
        labelColor: Colors.grey[800],
        unselectedLabelColor: Colors.grey[500],
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        onTap: (index) {
          // 🔥 FIXED: Correct tab index mapping
          switch (index) {
            case 0:
              _selectedFilter = 'All';
              break;
            case 1:
              _selectedFilter = 'Delivered'; // ✅ Fixed: was 'Active' before
              break;
          }
          _applyFilter();
          print('Selected filter: $_selectedFilter'); // Debug print
          print('Filtered orders count: ${_filteredOrders.length}'); // Debug print
        },
        tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
      ),
    );
  }

  Widget _buildStatsHeader() {
    return ScaleTransition(
      scale: _statsScaleAnimation,
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black!, Colors.grey[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total Orders',
                _orders.length.toString(),
                Icons.shopping_bag_outlined,
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[400]!.withOpacity(0.6),
            ),
            Expanded(
              child: _buildStatItem(
                'Active',
                _orders.where((o) => o.orderStatus.toLowerCase() != 'delivered').length.toString(),
                Icons.local_shipping_outlined,
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[400]!.withOpacity(0.6),
            ),
            Expanded(
              child: _buildStatItem(
                'Delivered',
                _orders.where((o) => o.orderStatus.toLowerCase() == 'delivered').length.toString(),
                Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animationValue),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[800]!),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Loading your orders...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_filteredOrders.isEmpty) return _buildEmptyState();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];
          return _buildOrderCard(order, index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 70,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 32),
          Text(
            _selectedFilter == 'Delivered' ? 'No Delivered Orders' : 'No Orders Yet',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Text(
            _selectedFilter == 'Delivered'
                ? 'You don\'t have any delivered orders yet'
                : 'Start shopping to see your orders here',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[800]!, Colors.black],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
              label: Text(
                'Start Shopping',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrdersModel order, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 150)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _navigateToOrderTracking(order.orderId), // ✅ FIXED: Use the new navigation method
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Tooltip(
                                message: 'Order #${order.orderId}',
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: TextStyle(color: Colors.white, fontSize: 12),
                                waitDuration: Duration(milliseconds: 500),
                                child: Text(
                                  'Order #${order.orderId}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Flexible(child: _buildAnimatedStatusChip(order.orderStatus)),
                        ],
                      ),

                      SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[700]),
                          ),
                          SizedBox(width: 12),
                          Text(
                            _formatDate(order.orderDate),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '\$${order.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.white,
                              child: InkWell(
                                onTap: () => _navigateToOrderTracking(order.orderId), // ✅ FIXED: Use the new navigation method
                                borderRadius: BorderRadius.circular(12),
                                splashColor: Colors.white,
                                highlightColor: Colors.white,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Color(0xFFF97316), width: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.track_changes_outlined,
                                        size: 20,
                                        color: Color(0xFFF97316),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Track Order',
                                        style: TextStyle(
                                          color: Color(0xFFF97316),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[800]!, Colors.black],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => _navigateToOrderTracking(order.orderId), // ✅ FIXED: Use the new navigation method
                              icon: Icon(Icons.arrow_forward_outlined, color: Colors.white, size: 22),
                              tooltip: 'View Details',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStatusChip(String status) {
    Color borderColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        borderColor = Colors.orange[600]!;
        icon = Icons.pending_outlined;
        break;
      case 'order placed':
        borderColor = Colors.orange!;
        icon = Icons.shopping_bag_outlined;
        break;
      case 'approved':
        borderColor = Colors.green[600]!;
        icon = Icons.check_circle_outline;
        break;
      case 'processing':
        borderColor = Colors.purple[600]!;
        icon = Icons.settings_outlined;
        break;
      case 'shipped':
        borderColor = Colors.indigo[600]!;
        icon = Icons.local_shipping_outlined;
        break;
      case 'out for delivery':
        borderColor = Colors.teal[600]!;
        icon = Icons.delivery_dining_outlined;
        break;
      case 'delivered':
        borderColor = Colors.green[700]!;
        icon = Icons.check_circle_outline;
        break;
      default:
        borderColor = Colors.grey[600]!;
        icon = Icons.help_outline;
    }

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: borderColor),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    status,
                    style: TextStyle(
                      color: borderColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _avatarController.dispose();
    _cardAnimationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }
}