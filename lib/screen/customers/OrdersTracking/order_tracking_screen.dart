// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:project/screen/model/ProductModel.dart';
// // import 'package:project/screen/model/order_tracker_model.dart';
// // import 'package:project/screen/model/orders_model.dart';
// // import 'package:project/screen/model/selected_area_model.dart';
// // import 'package:project/screen/model/status_history_model.dart';
// // import 'package:project/screen/model/user_info_model.dart';
// //
// //
// // class OrderTrackingScreen extends StatefulWidget {
// //   final List<OrdersModel> order;
// //
// //   const OrderTrackingScreen({Key? key, required this.order}) : super(key: key);
// //
// //   @override
// //   _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
// // }
// //
// // class _OrderTrackingScreenState extends State<OrderTrackingScreen>
// //     with TickerProviderStateMixin {
// //   OrderTrackerModel? _orderTracker;
// //   List<StatusHistoryModel> _statusHistory = [];
// //   ProductModel? _product;
// //   UserInfoModel? _userInfo;
// //   SelectedAreaModel? _selectedArea;
// //   bool _isLoading = true;
// //
// //   late AnimationController _progressAnimationController;
// //   late AnimationController _pulseAnimationController;
// //   late Animation<double> _progressAnimation;
// //   late Animation<double> _pulseAnimation;
// //
// //   final List<Map<String, dynamic>> _trackingSteps = [
// //     {
// //       'status': 'Order Placed',
// //       'icon': Icons.shopping_cart,
// //       'description': 'Your order has been placed successfully',
// //     },
// //     {
// //       'status': 'Approved',
// //       'icon': Icons.verified,
// //       'description': 'Order confirmed and being prepared',
// //     },
// //     {
// //       'status': 'Processing',
// //       'icon': Icons.settings,
// //       'description': 'Your order is being processed',
// //     },
// //     {
// //       'status': 'Shipped',
// //       'icon': Icons.local_shipping,
// //       'description': 'Order has been shipped',
// //     },
// //     {
// //       'status': 'Out for Delivery',
// //       'icon': Icons.delivery_dining,
// //       'description': 'Order is out for delivery',
// //     },
// //     {
// //       'status': 'Delivered',
// //       'icon': Icons.check_circle,
// //       'description': 'Order delivered successfully',
// //     },
// //   ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _progressAnimationController = AnimationController(
// //       duration: Duration(milliseconds: 2000),
// //       vsync: this,
// //     );
// //     _pulseAnimationController = AnimationController(
// //       duration: Duration(milliseconds: 1500),
// //       vsync: this,
// //     );
// //
// //     _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
// //       CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOut),
// //     );
// //
// //     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
// //       CurvedAnimation(parent: _pulseAnimationController, curve: Curves.elasticInOut),
// //     );
// //
// //     _pulseAnimationController.repeat(reverse: true);
// //     _loadTrackingData();
// //   }
// //
// //   Future<void> _loadTrackingData() async {
// //     try {
// //       // Load order tracker
// //       QuerySnapshot trackerQuery = await FirebaseFirestore.instance
// //           .collection('OrderTracker')
// //           .where('orderId', isEqualTo: widget.order.orderId)
// //           .limit(1)
// //           .get();
// //
// //       if (trackerQuery.docs.isNotEmpty) {
// //         _orderTracker = OrderTrackerModel.fromSnapshot(trackerQuery.docs.first);
// //       }
// //
// //       // Load status history
// //       QuerySnapshot historyQuery = await FirebaseFirestore.instance
// //           .collection('StatusHistory')
// //           .where('orderId', isEqualTo: widget.order.orderId)
// //           .orderBy('timestamp', descending: false)
// //           .get();
// //
// //       _statusHistory = StatusHistoryModel.fromQuerySnapshot(historyQuery);
// //
// //       // Load product details
// //       DocumentSnapshot productDoc = await FirebaseFirestore.instance
// //           .collection('Books')
// //           .doc(widget.order.productId)
// //           .get();
// //
// //       if (productDoc.exists) {
// //         _product = ProductModel.fromSnapshot(productDoc);
// //       }
// //
// //       // Load user info
// //       QuerySnapshot userInfoQuery = await FirebaseFirestore.instance
// //           .collection('UserInfo')
// //           .where('userId', isEqualTo: widget.order.userId)
// //           .orderBy('FieldValue.serverTimestamp()', descending: true)
// //           .limit(1)
// //           .get();
// //
// //       if (userInfoQuery.docs.isNotEmpty) {
// //         _userInfo = UserInfoModel.fromSnapshot(userInfoQuery.docs.first);
// //
// //         // Load selected area
// //         if (_userInfo!.selectedAreaId.isNotEmpty) {
// //           DocumentSnapshot areaDoc = await FirebaseFirestore.instance
// //               .collection('SelectedArea')
// //               .doc(_userInfo!.selectedAreaId)
// //               .get();
// //
// //           if (areaDoc.exists) {
// //             _selectedArea = SelectedAreaModel.fromSnapshot(areaDoc);
// //           }
// //         }
// //       }
// //
// //       _progressAnimationController.forward();
// //     } catch (e) {
// //       print('Error loading tracking data: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Error loading tracking data: $e'),
// //           backgroundColor: Colors.red[400],
// //         ),
// //       );
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }
// //
// //   int _getCurrentStepIndex() {
// //     String currentStatus = widget.order.orderStatus;
// //     for (int i = 0; i < _trackingSteps.length; i++) {
// //       if (_trackingSteps[i]['status'].toString().toLowerCase() ==
// //           currentStatus.toLowerCase()) {
// //         return i;
// //       }
// //     }
// //     return 0;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[50],
// //       body: _isLoading
// //           ? _buildLoadingState()
// //           : CustomScrollView(
// //               slivers: [
// //                 _buildSliverAppBar(),
// //                 SliverToBoxAdapter(
// //                   child: Column(
// //                     children: [
// //                       _buildOrderSummary(),
// //                       _buildTrackingProgress(),
// //                       _buildEstimatedDelivery(),
// //                       _buildProductDetails(),
// //                       _buildDeliveryAddress(),
// //                       _buildStatusHistory(),
// //                       SizedBox(height: 100),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //       floatingActionButton: _buildFloatingActions(),
// //     );
// //   }
// //
// //   Widget _buildLoadingState() {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         foregroundColor: Colors.black,
// //       ),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             CircularProgressIndicator(
// //               valueColor: AlwaysStoppedAnimation<Color>(Colors.black!),
// //             ),
// //             SizedBox(height: 16),
// //             Text(
// //               'Loading tracking information...',
// //               style: TextStyle(
// //                 color: Colors.grey[600],
// //                 fontSize: 16,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSliverAppBar() {
// //     return SliverAppBar(
// //       expandedHeight: 150,
// //       floating: false,
// //       pinned: true,
// //       backgroundColor: Colors.white,
// //       foregroundColor: Colors.white,
// //       flexibleSpace: FlexibleSpaceBar(
// //         title: Text(
// //
// //           'Track Your Order',
// //           style: TextStyle(
// //             color: Colors.white,
// //             fontWeight: FontWeight.bold,
// //             shadows: [
// //               Shadow(
// //                 offset: Offset(0, 1),
// //                 blurRadius: 3,
// //                 color: Colors.white.withOpacity(0.3),
// //               ),
// //             ],
// //           ),
// //         ),
// //         background: Container(
// //           decoration: BoxDecoration(
// //             gradient: LinearGradient(
// //               colors: [Colors.black!, Colors.black54!],
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //             ),
// //           ),
// //           child: Center(
// //             child: AnimatedBuilder(
// //               animation: _pulseAnimation,
// //               builder: (context, child) {
// //                 return Transform.scale(
// //                   scale: _pulseAnimation.value,
// //                   child: Icon(
// //                     Icons.track_changes,
// //                     size: 50,
// //                     color: Colors.white,
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // Widget _buildOrderSummary() {
// //   //   return Container(
// //   //     margin: EdgeInsets.all(16),
// //   //     padding: EdgeInsets.all(20),
// //   //     decoration: BoxDecoration(
// //   //       color: Colors.white,
// //   //       borderRadius: BorderRadius.circular(16),
// //   //       boxShadow: [
// //   //         BoxShadow(
// //   //           color: Colors.black.withOpacity(0.05),
// //   //           blurRadius: 10,
// //   //           offset: Offset(0, 2),
// //   //         ),
// //   //       ],
// //   //     ),
// //   //     child: Column(
// //   //       crossAxisAlignment: CrossAxisAlignment.start,
// //   //       children: [
// //   //         Row(
// //   //           children: [
// //   //             Container(
// //   //               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //   //               decoration: BoxDecoration(
// //   //                 color: Colors.blue[50],
// //   //                 borderRadius: BorderRadius.circular(20),
// //   //               ),
// //   //               child: Text(
// //   //                 'Order #${widget.order.orderId}',
// //   //                 style: TextStyle(
// //   //                   color: Colors.blue[600],
// //   //                   fontWeight: FontWeight.bold,
// //   //                 ),
// //   //               ),
// //   //             ),
// //   //             Spacer(),
// //   //             _buildAnimatedStatusChip(widget.order.orderStatus),
// //   //           ],
// //   //         ),
// //   //         SizedBox(height: 16),
// //   //         Row(
// //   //           children: [
// //   //             Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
// //   //             SizedBox(width: 8),
// //   //             Text(
// //   //               'Ordered on ${_formatDate(widget.order.orderDate)}',
// //   //               style: TextStyle(color: Colors.grey[600]),
// //   //             ),
// //   //             Spacer(),
// //   //             Text(
// //   //               '\$${widget.order.totalAmount.toStringAsFixed(2)}',
// //   //               style: TextStyle(
// //   //                 fontSize: 18,
// //   //                 fontWeight: FontWeight.bold,
// //   //                 color: Colors.green[600],
// //   //               ),
// //   //             ),
// //   //           ],
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// //
// //   Widget _buildOrderSummary() {
// //     return Container(
// //       margin: EdgeInsets.all(16),
// //       padding: EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           // Determine if we're on a small screen
// //           bool isSmallScreen = constraints.maxWidth < 400;
// //
// //           return Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Top Row - Order ID and Status
// //               isSmallScreen
// //                   ? _buildSmallScreenHeader()
// //                   : _buildLargeScreenHeader(),
// //
// //               SizedBox(height: 16),
// //
// //               // Bottom Row - Date and Price
// //               isSmallScreen
// //                   ? _buildSmallScreenFooter()
// //                   : _buildLargeScreenFooter(),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// // // For small screens - Stack vertically
// //   Widget _buildSmallScreenHeader() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         // Order ID - Full width
// //         Container(
// //           width: double.infinity,
// //           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //           decoration: BoxDecoration(
// //             color: Colors.blue[50],
// //             borderRadius: BorderRadius.circular(20),
// //           ),
// //           child: Text(
// //             'Order #${widget.order.orderId}',
// //             style: TextStyle(
// //               color: Colors.blue[600],
// //               fontWeight: FontWeight.bold,
// //               fontSize: 13,
// //             ),
// //             overflow: TextOverflow.ellipsis,
// //             maxLines: 1,
// //           ),
// //         ),
// //         SizedBox(height: 12),
// //         // Status Badge - Full width
// //         Container(
// //           width: double.infinity,
// //           child: Row(
// //             children: [
// //               Expanded(child: _buildAnimatedStatusChip(widget.order.orderStatus)),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// // // For larger screens - Side by side
// //   Widget _buildLargeScreenHeader() {
// //     return Row(
// //       children: [
// //         // Order ID - Flexible to prevent overflow
// //         Flexible(
// //           flex: 3,
// //           child: Container(
// //             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //             decoration: BoxDecoration(
// //               color: Colors.blue[50],
// //               borderRadius: BorderRadius.circular(20),
// //             ),
// //             child: Text(
// //               'Order #${widget.order.orderId}',
// //               style: TextStyle(
// //                 color: Colors.blue[600],
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 13,
// //               ),
// //               overflow: TextOverflow.ellipsis,
// //               maxLines: 1,
// //             ),
// //           ),
// //         ),
// //         SizedBox(width: 12),
// //         // Status Badge - Flexible to prevent overflow
// //         Flexible(
// //           flex: 2,
// //           child: _buildAnimatedStatusChip(widget.order.orderStatus),
// //         ),
// //       ],
// //     );
// //   }
// //
// // // For small screens - Stack vertically
// //   Widget _buildSmallScreenFooter() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         // Date Row
// //         Row(
// //           children: [
// //             Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
// //             SizedBox(width: 8),
// //             Expanded(
// //               child: Text(
// //                 'Ordered on ${_formatDate(widget.order.orderDate)}',
// //                 style: TextStyle(
// //                   color: Colors.grey[600],
// //                   fontSize: 14,
// //                 ),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ),
// //           ],
// //         ),
// //         SizedBox(height: 12),
// //         // Price Row
// //         Container(
// //           width: double.infinity,
// //           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //           decoration: BoxDecoration(
// //             color: Colors.green[50],
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Text(
// //             '\$${widget.order.totalAmount.toStringAsFixed(2)}',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.green[600],
// //             ),
// //             textAlign: TextAlign.center,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// // // For larger screens - Side by side
// //   Widget _buildLargeScreenFooter() {
// //     return Row(
// //       children: [
// //         // Date section - Flexible
// //         Flexible(
// //           flex: 3,
// //           child: Row(
// //             children: [
// //               Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
// //               SizedBox(width: 8),
// //               Expanded(
// //                 child: Text(
// //                   'Ordered on ${_formatDate(widget.order.orderDate)}',
// //                   style: TextStyle(
// //                     color: Colors.grey[600],
// //                     fontSize: 14,
// //                   ),
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         SizedBox(width: 16),
// //         // Price section - Fixed width
// //         Container(
// //           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //           decoration: BoxDecoration(
// //             color: Colors.green[50],
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Text(
// //             '\$${widget.order.totalAmount.toStringAsFixed(2)}',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.green[600],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// // // Enhanced responsive status chip
// //   Widget _buildAnimatedStatusChip(String status) {
// //     Color borderColor;
// //     Color backgroundColor;
// //     IconData icon;
// //
// //     switch (status.toLowerCase()) {
// //       case 'pending':
// //         borderColor = Color(0xFFF59E0B);
// //         backgroundColor = Colors.white;
// //         icon = Icons.pending_outlined;
// //         break;
// //       case 'order placed':
// //         borderColor = Color(0xFF3B82F6);
// //         backgroundColor = Colors.white;
// //         icon = Icons.shopping_bag_outlined;
// //         break;
// //       case 'approved':
// //         borderColor = Color(0xFF10B981);
// //         backgroundColor = Color(0xFFD1FAE5);
// //         icon = Icons.check_circle_outline;
// //         break;
// //       case 'processing':
// //         borderColor = Color(0xFF8B5CF6);
// //         backgroundColor = Color(0xFFEDE9FE);
// //         icon = Icons.settings_outlined;
// //         break;
// //       case 'shipped':
// //         borderColor = Color(0xFF6366F1);
// //         backgroundColor = Color(0xFFE0E7FF);
// //         icon = Icons.local_shipping_outlined;
// //         break;
// //       case 'out for delivery':
// //         borderColor = Color(0xFF06B6D4);
// //         backgroundColor = Color(0xFFCFFAFE);
// //         icon = Icons.delivery_dining_outlined;
// //         break;
// //       case 'delivered':
// //         borderColor = Color(0xFF059669);
// //         backgroundColor = Color(0xFFD1FAE5);
// //         icon = Icons.check_circle_outline;
// //         break;
// //       default:
// //         borderColor = Color(0xFF6B7280);
// //         backgroundColor = Color(0xFFF3F4F6);
// //         icon = Icons.help_outline;
// //     }
// //
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         // Adjust font size based on available width
// //         double fontSize = constraints.maxWidth < 120 ? 10 : 12;
// //         double iconSize = constraints.maxWidth < 120 ? 12 : 14;
// //
// //         return TweenAnimationBuilder<double>(
// //           duration: Duration(milliseconds: 1200),
// //           tween: Tween(begin: 0.0, end: 1.0),
// //           builder: (context, value, child) {
// //             return Transform.scale(
// //               scale: 0.8 + (0.2 * value),
// //               child: Container(
// //                 padding: EdgeInsets.symmetric(
// //                     horizontal: constraints.maxWidth < 120 ? 8 : 12,
// //                     vertical: 6
// //                 ),
// //                 decoration: BoxDecoration(
// //                   color: backgroundColor,
// //                   borderRadius: BorderRadius.circular(20),
// //                   border: Border.all(color: borderColor, width: 1.5),
// //                 ),
// //                 child: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     Icon(icon, size: iconSize, color: borderColor),
// //                     SizedBox(width: 4),
// //                     Flexible(
// //                       child: Text(
// //                         status,
// //                         style: TextStyle(
// //                           color: borderColor,
// //                           fontSize: fontSize,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                         overflow: TextOverflow.ellipsis,
// //                         maxLines: 1,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// //
// // // Alternative ultra-responsive version using MediaQuery
// //   Widget _buildOrderSummaryUltraResponsive() {
// //     return Container(
// //       margin: EdgeInsets.all(16),
// //       padding: EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: MediaQuery.of(context).size.width < 350
// //           ? _buildExtraSmallLayout()
// //           : MediaQuery.of(context).size.width < 500
// //           ? _buildSmallLayout()
// //           : _buildLargeLayout(),
// //     );
// //   }
// //
// // // Extra small screens (< 350px)
// //   Widget _buildExtraSmallLayout() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         // Order ID
// //         Container(
// //           width: double.infinity,
// //           padding: EdgeInsets.all(12),
// //           decoration: BoxDecoration(
// //             color: Colors.blue[50],
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 'Order ID',
// //                 style: TextStyle(
// //                   color: Colors.blue[400],
// //                   fontSize: 10,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //               SizedBox(height: 4),
// //               Text(
// //                 '#${widget.order.orderId}',
// //                 style: TextStyle(
// //                   color: Colors.blue[600],
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 12,
// //                 ),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ],
// //           ),
// //         ),
// //         SizedBox(height: 12),
// //
// //         // Status
// //         _buildAnimatedStatusChip(widget.order.orderStatus),
// //         SizedBox(height: 16),
// //
// //         // Date
// //         Row(
// //           children: [
// //             Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
// //             SizedBox(width: 6),
// //             Expanded(
// //               child: Text(
// //                 _formatDate(widget.order.orderDate),
// //                 style: TextStyle(color: Colors.grey[600], fontSize: 12),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ),
// //           ],
// //         ),
// //         SizedBox(height: 12),
// //
// //         // Price
// //         Container(
// //           width: double.infinity,
// //           padding: EdgeInsets.all(12),
// //           decoration: BoxDecoration(
// //             color: Colors.green[50],
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Text(
// //             '\$${widget.order.totalAmount.toStringAsFixed(2)}',
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.green[600],
// //             ),
// //             textAlign: TextAlign.center,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// // // Small screens (350px - 500px)
// //   Widget _buildSmallLayout() {
// //     return Column(
// //       children: [
// //         Row(
// //           children: [
// //             Expanded(
// //               flex: 2,
// //               child: Container(
// //                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //                 decoration: BoxDecoration(
// //                   color: Colors.blue[50],
// //                   borderRadius: BorderRadius.circular(16),
// //                 ),
// //                 child: Text(
// //                   'Order #${widget.order.orderId}',
// //                   style: TextStyle(
// //                     color: Colors.blue[600],
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 11,
// //                   ),
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //             ),
// //             SizedBox(width: 8),
// //             Expanded(
// //               flex: 1,
// //               child: _buildAnimatedStatusChip(widget.order.orderStatus),
// //             ),
// //           ],
// //         ),
// //         SizedBox(height: 16),
// //         Row(
// //           children: [
// //             Expanded(
// //               child: Row(
// //                 children: [
// //                   Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
// //                   SizedBox(width: 6),
// //                   Expanded(
// //                     child: Text(
// //                       _formatDate(widget.order.orderDate),
// //                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Container(
// //               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //               decoration: BoxDecoration(
// //                 color: Colors.green[50],
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Text(
// //                 '\$${widget.order.totalAmount.toStringAsFixed(2)}',
// //                 style: TextStyle(
// //                   fontSize: 14,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.green[600],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// //
// // // Large screens (> 500px)
// //   Widget _buildLargeLayout() {
// //     return Column(
// //       children: [
// //         Row(
// //           children: [
// //             Flexible(
// //               flex: 3,
// //               child: Container(
// //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //                 decoration: BoxDecoration(
// //                   color: Colors.blue[50],
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: Text(
// //                   'Order #${widget.order.orderId}',
// //                   style: TextStyle(
// //                     color: Colors.blue[600],
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //             ),
// //             SizedBox(width: 12),
// //             Flexible(
// //               flex: 2,
// //               child: _buildAnimatedStatusChip(widget.order.orderStatus),
// //             ),
// //           ],
// //         ),
// //         SizedBox(height: 16),
// //         Row(
// //           children: [
// //             Expanded(
// //               child: Row(
// //                 children: [
// //                   Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
// //                   SizedBox(width: 8),
// //                   Expanded(
// //                     child: Text(
// //                       'Ordered on ${_formatDate(widget.order.orderDate)}',
// //                       style: TextStyle(color: Colors.grey[600]),
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Container(
// //               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //               decoration: BoxDecoration(
// //                 color: Colors.green[50],
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Text(
// //                 '\$${widget.order.totalAmount.toStringAsFixed(2)}',
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.green[600],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// //
// // // Helper method for date formatting
// //   String _formatDate(DateTime date) {
// //     return '${date.day}/${date.month}/${date.year}';
// //   }
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //   Widget _buildTrackingProgress() {
// //     int currentStep = _getCurrentStepIndex();
// //
// //     return Container(
// //       margin: EdgeInsets.symmetric(horizontal: 16),
// //       padding: EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'Order Progress',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.grey[800],
// //             ),
// //           ),
// //           SizedBox(height: 20),
// //           ...List.generate(_trackingSteps.length, (index) {
// //             bool isCompleted = index <= currentStep;
// //             bool isCurrent = index == currentStep;
// //             bool isLast = index == _trackingSteps.length - 1;
// //
// //             return _buildTrackingStep(
// //               _trackingSteps[index],
// //               isCompleted,
// //               isCurrent,
// //               isLast,
// //               index,
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTrackingStep(
// //     Map<String, dynamic> step,
// //     bool isCompleted,
// //     bool isCurrent,
// //     bool isLast,
// //     int index,
// //   ) {
// //     Color stepColor = isCompleted ? Colors.green[600]! : Colors.grey[300]!;
// //     Color currentColor = isCurrent ? Colors.blue[600]! : stepColor;
// //
// //     return AnimatedBuilder(
// //       animation: _progressAnimation,
// //       builder: (context, child) {
// //         double animationValue = _progressAnimation.value;
// //         if (index > _getCurrentStepIndex()) {
// //           animationValue = 0.0;
// //         }
// //
// //         return TweenAnimationBuilder<double>(
// //           duration: Duration(milliseconds: 800 + (index * 200)),
// //           tween: Tween(begin: 0.0, end: animationValue),
// //           builder: (context, value, child) {
// //             return Opacity(
// //               opacity: 0.3 + (0.7 * value),
// //               child: Transform.translate(
// //                 offset: Offset(50 * (1 - value), 0),
// //                 child: Row(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Column(
// //                       children: [
// //                         AnimatedContainer(
// //                           duration: Duration(milliseconds: 500),
// //                           width: 40,
// //                           height: 40,
// //                           decoration: BoxDecoration(
// //                             color: isCurrent ? currentColor : stepColor,
// //                             shape: BoxShape.circle,
// //                             boxShadow: isCurrent ? [
// //                               BoxShadow(
// //                                 color: currentColor.withOpacity(0.4),
// //                                 blurRadius: 10,
// //                                 spreadRadius: 2,
// //                               ),
// //                             ] : [],
// //                           ),
// //                           child: AnimatedSwitcher(
// //                             duration: Duration(milliseconds: 300),
// //                             child: Icon(
// //                               isCompleted ? Icons.check : step['icon'],
// //                               key: ValueKey(isCompleted),
// //                               color: Colors.white,
// //                               size: 20,
// //                             ),
// //                           ),
// //                         ),
// //                         if (!isLast)
// //                           AnimatedContainer(
// //                             duration: Duration(milliseconds: 500),
// //                             width: 2,
// //                             height: 40,
// //                             color: isCompleted ? Colors.green[600] : Colors.grey[300],
// //                             margin: EdgeInsets.symmetric(vertical: 8),
// //                           ),
// //                       ],
// //                     ),
// //                     SizedBox(width: 16),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             step['status'],
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 16,
// //                               color: isCompleted ? Colors.grey[800] : Colors.grey[500],
// //                             ),
// //                           ),
// //                           SizedBox(height: 4),
// //                           Text(
// //                             step['description'],
// //                             style: TextStyle(
// //                               color: Colors.grey[600],
// //                               fontSize: 14,
// //                             ),
// //                           ),
// //                           if (isCurrent) ...[
// //                             SizedBox(height: 8),
// //                             Container(
// //                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                               decoration: BoxDecoration(
// //                                 color: Colors.blue[50],
// //                                 borderRadius: BorderRadius.circular(12),
// //                               ),
// //                               child: Text(
// //                                 'Current Status',
// //                                 style: TextStyle(
// //                                   color: Colors.blue[600],
// //                                   fontSize: 12,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                           SizedBox(height: 16),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget _buildEstimatedDelivery() {
// //     DateTime estimatedDate = widget.order.deliveryDate ??
// //         DateTime.now().add(Duration(days: 3));
// //
// //     return Container(
// //       margin: EdgeInsets.all(16),
// //       padding: EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: [Colors.orange[400]!, Colors.orange[400]!],
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //         ),
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.orange.withOpacity(0.3),
// //             blurRadius: 10,
// //             offset: Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             padding: EdgeInsets.all(12),
// //             decoration: BoxDecoration(
// //               color: Colors.white.withOpacity(0.2),
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Icon(
// //               Icons.local_shipping,
// //               color: Colors.white,
// //               size: 24,
// //             ),
// //           ),
// //           SizedBox(width: 16),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Estimated Delivery',
// //                   style: TextStyle(
// //                     color: Colors.white.withOpacity(0.9),
// //                     fontSize: 14,
// //                   ),
// //                 ),
// //                 SizedBox(height: 4),
// //                 Text(
// //                   _formatDate(estimatedDate),
// //                   style: TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Container(
// //             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //             decoration: BoxDecoration(
// //               color: Colors.white.withOpacity(0.2),
// //               borderRadius: BorderRadius.circular(20),
// //             ),
// //             child: Text(
// //               _getDaysRemaining(estimatedDate),
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 12,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProductDetails() {
// //     if (_product == null) return SizedBox();
// //
// //     return Container(
// //       margin: EdgeInsets.symmetric(horizontal: 16),
// //       padding: EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'Product Details',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.grey[800],
// //             ),
// //           ),
// //           SizedBox(height: 16),
// //           Row(
// //             children: [
// //               ClipRRect(
// //                 borderRadius: BorderRadius.circular(12),
// //                 child: Image.network(
// //                   _product!.imgurl,
// //                   width: 80,
// //                   height: 80,
// //                   fit: BoxFit.cover,
// //                   errorBuilder: (context, error, stackTrace) =>
// //                       Container(
// //                     width: 80,
// //                     height: 80,
// //                     color: Colors.grey[300],
// //                     child: Icon(Icons.image),
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(width: 16),
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       _product!.name,
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                     SizedBox(height: 4),
// //                     Text(
// //                       _product!.description,
// //                       style: TextStyle(color: Colors.grey[600]),
// //                       maxLines: 2,
// //                       overflow: TextOverflow.ellipsis,
// //                     ),
// //                     SizedBox(height: 8),
// //                     Text(
// //                       '\$${_product!.price.toStringAsFixed(2)}',
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.green[600],
// //                         fontSize: 16,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDeliveryAddress() {
// //     if (_userInfo == null) return SizedBox();
// //
// //     return Container(
// //       margin: EdgeInsets.all(16),
// //       padding: EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Icon(Icons.location_on, color: Colors.red[400]),
// //               SizedBox(width: 8),
// //               Text(
// //                 'Delivery Address',
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.grey[800],
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 16),
// //           if (_selectedArea != null) ...[
// //             Text(
// //               'Area: ${_selectedArea!.area}',
// //               style: TextStyle(
// //                 fontWeight: FontWeight.w500,
// //                 color: Colors.grey[700],
// //               ),
// //             ),
// //             SizedBox(height: 8),
// //           ],
// //           Text(
// //             _userInfo!.deliveryAddress,
// //             style: TextStyle(
// //               color: Colors.grey[600],
// //               fontSize: 16,
// //             ),
// //           ),
// //           SizedBox(height: 8),
// //           Text(
// //             'Phone: ${_userInfo!.phone}',
// //             style: TextStyle(
// //               color: Colors.grey[600],
// //               fontSize: 14,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatusHistory() {
// //     if (_statusHistory.isEmpty) return SizedBox();
// //
// //     return Container(
// //       margin: EdgeInsets.all(16),
// //       padding: EdgeInsets.all(20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'Status Updates',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.grey[800],
// //             ),
// //           ),
// //           SizedBox(height: 16),
// //           ...List.generate(_statusHistory.length, (index) {
// //             final history = _statusHistory[index];
// //             return TweenAnimationBuilder<double>(
// //               duration: Duration(milliseconds: 600 + (index * 100)),
// //               tween: Tween(begin: 0.0, end: 1.0),
// //               builder: (context, value, child) {
// //                 return Transform.translate(
// //                   offset: Offset(30 * (1 - value), 0),
// //                   child: Opacity(
// //                     opacity: value,
// //                     child: Container(
// //                       margin: EdgeInsets.only(bottom: 12),
// //                       padding: EdgeInsets.all(16),
// //                       decoration: BoxDecoration(
// //                         color: Colors.blue[50],
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border(
// //                           left: BorderSide(
// //                             color: Colors.blue[600]!,
// //                             width: 4,
// //                           ),
// //                         ),
// //
// //                       ),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Row(
// //                             children: [
// //                               Text(
// //                                 history.status,
// //                                 style: TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.blue[600],
// //                                 ),
// //                               ),
// //                               Spacer(),
// //                               Text(
// //                                 _formatDateTime(history.timestamp),
// //                                 style: TextStyle(
// //                                   color: Colors.grey[500],
// //                                   fontSize: 12,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           SizedBox(height: 8),
// //                           Text(
// //                             history.message,
// //                             style: TextStyle(color: Colors.grey[700]),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               },
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFloatingActions() {
// //     return Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         FloatingActionButton(
// //           heroTag: "refresh",
// //           onPressed: () {
// //             _loadTrackingData();
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(
// //                 content: Text('Successfully! Tracking information refreshed '),
// //                 backgroundColor: Colors.black,
// //               ),
// //             );
// //           },
// //           backgroundColor: Colors.blue[600],
// //           child: Icon(Icons.refresh, color: Colors.white),
// //         ),
// //         SizedBox(height: 16),
// //         FloatingActionButton.extended(
// //           heroTag: "support",
// //           onPressed: () {
// //               // TODO: Implement customer support
// //             ScaffoldMessenger.of(context).showSnackBar(
// //               SnackBar(
// //                 content: Text('customer support coming soon!'),
// //                 backgroundColor: Colors.orange[400],
// //               ),
// //             );
// //           },
// //           backgroundColor: Colors.orange[400],
// //           icon: Icon(Icons.support_agent, color: Colors.white),
// //           label: Text(
// //             'Support',
// //             style: TextStyle(color: Colors.white),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   // String _formatDate(DateTime date) {
// //   //   return '${date.day}/${date.month}/${date.year}';
// //   // }
// //
// //   String _formatDateTime(DateTime date) {
// //     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
// //   }
// //
// //   String _getDaysRemaining(DateTime deliveryDate) {
// //     int days = deliveryDate.difference(DateTime.now()).inDays;
// //     if (days < 0) return 'Overdue';
// //     if (days == 0) return 'Today';
// //     if (days == 1) return 'Tomorrow';
// //     return '$days days';
// //   }
// //
// //   @override
// //   void dispose() {
// //     _progressAnimationController.dispose();
// //     _pulseAnimationController.dispose();
// //     super.dispose();
// //   }
// // }
//
//
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:project/screen/model/ProductModel.dart';
// import 'package:project/screen/model/order_tracker_model.dart';
// import 'package:project/screen/model/orders_model.dart';
// import 'package:project/screen/model/selected_area_model.dart';
// import 'package:project/screen/model/status_history_model.dart';
// import 'package:project/screen/model/user_info_model.dart';
//
// class OrderTrackingScreen extends StatefulWidget {
//   final List<OrdersModel> order; // This is a list
//   const OrderTrackingScreen({Key? key, required this.order}) : super(key: key);
//
//   @override
//   _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
// }
//
// class _OrderTrackingScreenState extends State<OrderTrackingScreen>
//     with TickerProviderStateMixin {
//   OrderTrackerModel? _orderTracker;
//   List<StatusHistoryModel> _statusHistory = [];
//   List<ProductModel> _products = []; // Changed to list for multiple products
//   UserInfoModel? _userInfo;
//   SelectedAreaModel? _selectedArea;
//   bool _isLoading = true;
//
//   // Calculate totals from the order list
//   double get _totalAmount => widget.order.fold(0.0, (sum, order) => sum + order.totalAmount);
//   // int get _totalQuantity => widget.order.fold(0, (sum, order) => sum + order.quantity);
//   String get _orderId => widget.order.isNotEmpty ? widget.order.first.orderId : '';
//   String get _orderStatus => widget.order.isNotEmpty ? widget.order.first.orderStatus : '';
//   DateTime get _orderDate => widget.order.isNotEmpty ? widget.order.first.orderDate : DateTime.now();
//   String get _userId => widget.order.isNotEmpty ? widget.order.first.userId : '';
//
//   late AnimationController _progressAnimationController;
//   late AnimationController _pulseAnimationController;
//   late Animation<double> _progressAnimation;
//   late Animation<double> _pulseAnimation;
//
//   final List<Map<String, dynamic>> _trackingSteps = [
//     {
//       'status': 'Order Placed',
//       'icon': Icons.shopping_cart,
//       'description': 'Your order has been placed successfully',
//     },
//     {
//       'status': 'Approved',
//       'icon': Icons.verified,
//       'description': 'Order confirmed and being prepared',
//     },
//     {
//       'status': 'Processing',
//       'icon': Icons.settings,
//       'description': 'Your order is being processed',
//     },
//     {
//       'status': 'Shipped',
//       'icon': Icons.local_shipping,
//       'description': 'Order has been shipped',
//     },
//     {
//       'status': 'Out for Delivery',
//       'icon': Icons.delivery_dining,
//       'description': 'Order is out for delivery',
//     },
//     {
//       'status': 'Delivered',
//       'icon': Icons.check_circle,
//       'description': 'Order delivered successfully',
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _progressAnimationController = AnimationController(
//       duration: Duration(milliseconds: 2000),
//       vsync: this,
//     );
//     _pulseAnimationController = AnimationController(
//       duration: Duration(milliseconds: 1500),
//       vsync: this,
//     );
//
//     _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOut),
//     );
//
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(parent: _pulseAnimationController, curve: Curves.elasticInOut),
//     );
//
//     _pulseAnimationController.repeat(reverse: true);
//     _loadTrackingData();
//   }
//
//   Future<void> _loadTrackingData() async {
//     try {
//       if (widget.order.isEmpty) return;
//
//       // Load order tracker using the first order's orderId (since all have same orderId)
//       QuerySnapshot trackerQuery = await FirebaseFirestore.instance
//           .collection('OrderTracker')
//           .where('orderId', isEqualTo: _orderId)
//           .limit(1)
//           .get();
//
//       if (trackerQuery.docs.isNotEmpty) {
//         _orderTracker = OrderTrackerModel.fromSnapshot(trackerQuery.docs.first);
//       }
//
//       // Load status history
//       QuerySnapshot historyQuery = await FirebaseFirestore.instance
//           .collection('StatusHistory')
//           .where('orderId', isEqualTo: _orderId)
//           .orderBy('timestamp', descending: false)
//           .get();
//
//       _statusHistory = StatusHistoryModel.fromQuerySnapshot(historyQuery);
//
//       // Load product details for ALL products in the order
//       List<ProductModel> loadedProducts = [];
//       for (OrdersModel orderItem in widget.order) {
//         try {
//           DocumentSnapshot productDoc = await FirebaseFirestore.instance
//               .collection('Books')
//               .doc(orderItem.productId)
//               .get();
//
//           if (productDoc.exists) {
//             ProductModel product = ProductModel.fromSnapshot(productDoc);
//             loadedProducts.add(product);
//           }
//         } catch (e) {
//           print('Error loading product ${orderItem.productId}: $e');
//         }
//       }
//       _products = loadedProducts;
//
//       // Load user info
//       QuerySnapshot userInfoQuery = await FirebaseFirestore.instance
//           .collection('UserInfo')
//           .where('userId', isEqualTo: _userId)
//           .orderBy('FieldValue.serverTimestamp()', descending: true)
//           .limit(1)
//           .get();
//
//       if (userInfoQuery.docs.isNotEmpty) {
//         _userInfo = UserInfoModel.fromSnapshot(userInfoQuery.docs.first);
//
//         // Load selected area
//         if (_userInfo!.selectedAreaId.isNotEmpty) {
//           DocumentSnapshot areaDoc = await FirebaseFirestore.instance
//               .collection('SelectedArea')
//               .doc(_userInfo!.selectedAreaId)
//               .get();
//
//           if (areaDoc.exists) {
//             _selectedArea = SelectedAreaModel.fromSnapshot(areaDoc);
//           }
//         }
//       }
//
//       _progressAnimationController.forward();
//     } catch (e) {
//       print('Error loading tracking data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error loading tracking data: $e'),
//           backgroundColor: Colors.red[400],
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   int _getCurrentStepIndex() {
//     String currentStatus = _orderStatus;
//     for (int i = 0; i < _trackingSteps.length; i++) {
//       if (_trackingSteps[i]['status'].toString().toLowerCase() ==
//           currentStatus.toLowerCase()) {
//         return i;
//       }
//     }
//     return 0;
//   }
//
//
//
//
//
//   Future<int> getCartDocument(String cartId) async {
//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('Cart')
//           .doc(cartId)
//           .get();
//
//       if (snapshot.exists) {
//         // ✅ Convert to map
//         Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
//
//         int quantity = data['quantity'];
//        print("Quantity in function $quantity");
//          return quantity;
//           } else {
//         print('No such cart document found');
//         return 0;
//       }
//     } catch (e) {
//       print('Error fetching cart document: $e');
//       return 0;
//     }
//   }
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: _isLoading
//           ? _buildLoadingState()
//           : CustomScrollView(
//         slivers: [
//           _buildSliverAppBar(),
//           SliverToBoxAdapter(
//             child: Column(
//               children: [
//                 _buildOrderSummary(),
//                 _buildTrackingProgress(),
//                 _buildEstimatedDelivery(),
//                 _buildProductDetails(), // This will now show all products
//                 _buildDeliveryAddress(),
//                 _buildStatusHistory(),
//                 SizedBox(height: 100),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: _buildFloatingActions(),
//     );
//   }
//
//   // Updated Order Summary to show combined totals
//   Widget _buildOrderSummary() {
//     return Container(
//       margin: EdgeInsets.all(16),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Order ID and Status
//           Row(
//             children: [
//               Flexible(
//                 flex: 3,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     'Order #$_orderId',
//                     style: TextStyle(
//                       color: Colors.blue[600],
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 12),
//               Flexible(
//                 flex: 2,
//                 child: _buildAnimatedStatusChip(_orderStatus),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           // Date, Items Count, and Total Price
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
//                         SizedBox(width: 8),
//                         Text(
//                           'Ordered on ${_formatDate(_orderDate)}',
//                           style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(Icons.shopping_bag, size: 16, color: Colors.grey[500]),
//                         SizedBox(width: 8),
//                         // Text(
//                         //   '${widget.order.length} item(s) • Qty: $_totalQuantity',
//                         //   style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                         // ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '\$${_totalAmount.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green[600],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Updated Product Details to show all products
//   Widget _buildProductDetails() {
//     if (_products.isEmpty) return SizedBox();
//
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Order Items (${widget.order.length})',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           SizedBox(height: 16),
//           // List all products
//           ListView.separated(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: widget.order.length,
//             separatorBuilder: (context, index) => Divider(height: 24),
//             itemBuilder: (context, index) {
//               OrdersModel orderItem = widget.order[index];
//               ProductModel? product = _products.length > index ? _products[index] : null;
//
//               return _buildProductItem(orderItem, product);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// //   Widget _buildProductItem(OrdersModel orderItem, ProductModel? product) {
// //
// //
// // String? cartid = orderItem.cartId;
// // print("cartid$cartid");
// // int quantity = await getCartDocument(cartid);
// // print("Quantity is $quantity");
// //
// //
// //
// //
// //
// //     return Row(
// //       children: [
// //         // Product Image
// //         ClipRRect(
// //           borderRadius: BorderRadius.circular(12),
// //           child: product != null
// //               ? Image(
// //           image: MemoryImage(base64Decode(product.imgurl)),
// //           width: 60,
// //           height: 60,
// //           fit: BoxFit.cover,
// //           errorBuilder: (context, error, stackTrace) => Container(
// //           width: 60,
// //           height: 60,
// //           color: Colors.grey[300],
// //           child: Icon(Icons.image, size: 30),
// //           ),
// //           )
// //               : Container(
// //             width: 60,
// //             height: 60,
// //             color: Colors.grey[300],
// //             child: Icon(Icons.image, size: 30),
// //           ),
// //         ),
// //         SizedBox(width: 12),
// //         // Product Details
// //         Expanded(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 product?.name ?? 'Product Name',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 14,
// //                 ),
// //                 maxLines: 2,
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //               SizedBox(height: 4),
// //               // Text(
// //               //   'Qty: ${orderItem.}',
// //               //   style: TextStyle(
// //               //     color: Colors.grey[600],
// //               //     fontSize: 12,
// //               //   ),
// //               // ),
// //               SizedBox(height: 4),
// //               Text(
// //                 '\$${orderItem.totalAmount.toStringAsFixed(2)}',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.green[600],
// //                   fontSize: 14,
// //                 ),
// //               ),
// //               Text("Quantity: ${quantity}"),
// //
// //
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }
//
//   // Keep all other existing methods the same...
//
//
//   Widget _buildProductItem(OrdersModel orderItem, ProductModel? product) {
//     String? cartid = orderItem.cartId;
//     print("cartid $cartid");
//
//     return FutureBuilder<int>(
//       future: getCartDocument(cartid!), // assume it's not null
//       builder: (context, snapshot) {
//         int quantity = snapshot.data ?? 0;
//
//         return Row(
//           children: [
//             // Product Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: product != null
//                   ? Image(
//                 image: MemoryImage(base64Decode(product.imgurl)),
//                 width: 60,
//                 height: 60,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   width: 60,
//                   height: 60,
//                   color: Colors.grey[300],
//                   child: Icon(Icons.image, size: 30),
//                 ),
//               )
//                   : Container(
//                 width: 60,
//                 height: 60,
//                 color: Colors.grey[300],
//                 child: Icon(Icons.image, size: 30),
//               ),
//             ),
//             SizedBox(width: 12),
//
//             // Product Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product?.name ?? 'Product Name',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     '\$${orderItem.totalAmount.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green[600],
//                       fontSize: 14,
//                     ),
//                   ),
//                   snapshot.connectionState == ConnectionState.waiting
//                       ? Text("Loading qty...")
//                       : Text("Quantity: $quantity"),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//
//
//
//   Widget _buildLoadingState() {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.black!),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Loading tracking information...',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       expandedHeight: 150,
//       floating: false,
//       pinned: true,
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.white,
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(
//           'Track Your Order',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             shadows: [
//               Shadow(
//                 offset: Offset(0, 1),
//                 blurRadius: 3,
//                 color: Colors.white.withOpacity(0.3),
//               ),
//             ],
//           ),
//         ),
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.black!, Colors.black54!],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Center(
//             child: AnimatedBuilder(
//               animation: _pulseAnimation,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: _pulseAnimation.value,
//                   child: Icon(
//                     Icons.track_changes,
//                     size: 50,
//                     color: Colors.white,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAnimatedStatusChip(String status) {
//     Color borderColor;
//     Color backgroundColor;
//     IconData icon;
//
//     switch (status.toLowerCase()) {
//       case 'pending':
//         borderColor = Color(0xFFF59E0B);
//         backgroundColor = Colors.white;
//         icon = Icons.pending_outlined;
//         break;
//       case 'order placed':
//         borderColor = Color(0xFF3B82F6);
//         backgroundColor = Colors.white;
//         icon = Icons.shopping_bag_outlined;
//         break;
//       case 'approved':
//         borderColor = Color(0xFF10B981);
//         backgroundColor = Color(0xFFD1FAE5);
//         icon = Icons.check_circle_outline;
//         break;
//       case 'processing':
//         borderColor = Color(0xFF8B5CF6);
//         backgroundColor = Color(0xFFEDE9FE);
//         icon = Icons.settings_outlined;
//         break;
//       case 'shipped':
//         borderColor = Color(0xFF6366F1);
//         backgroundColor = Color(0xFFE0E7FF);
//         icon = Icons.local_shipping_outlined;
//         break;
//       case 'out for delivery':
//         borderColor = Color(0xFF06B6D4);
//         backgroundColor = Color(0xFFCFFAFE);
//         icon = Icons.delivery_dining_outlined;
//         break;
//       case 'delivered':
//         borderColor = Color(0xFF059669);
//         backgroundColor = Color(0xFFD1FAE5);
//         icon = Icons.check_circle_outline;
//         break;
//       default:
//         borderColor = Color(0xFF6B7280);
//         backgroundColor = Color(0xFFF3F4F6);
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
//               color: backgroundColor,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: borderColor, width: 1.5),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(icon, size: 14, color: borderColor),
//                 SizedBox(width: 4),
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
//   // Keep all other existing methods unchanged...
//   Widget _buildTrackingProgress() {
//     int currentStep = _getCurrentStepIndex();
//
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Order Progress',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           SizedBox(height: 20),
//           ...List.generate(_trackingSteps.length, (index) {
//             bool isCompleted = index <= currentStep;
//             bool isCurrent = index == currentStep;
//             bool isLast = index == _trackingSteps.length - 1;
//
//             return _buildTrackingStep(
//               _trackingSteps[index],
//               isCompleted,
//               isCurrent,
//               isLast,
//               index,
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTrackingStep(
//       Map<String, dynamic> step,
//       bool isCompleted,
//       bool isCurrent,
//       bool isLast,
//       int index,
//       ) {
//     Color stepColor = isCompleted ? Colors.green[600]! : Colors.grey[300]!;
//     Color currentColor = isCurrent ? Colors.blue[600]! : stepColor;
//
//     return AnimatedBuilder(
//       animation: _progressAnimation,
//       builder: (context, child) {
//         double animationValue = _progressAnimation.value;
//         if (index > _getCurrentStepIndex()) {
//           animationValue = 0.0;
//         }
//
//         return TweenAnimationBuilder<double>(
//           duration: Duration(milliseconds: 800 + (index * 200)),
//           tween: Tween(begin: 0.0, end: animationValue),
//           builder: (context, value, child) {
//             return Opacity(
//               opacity: 0.3 + (0.7 * value),
//               child: Transform.translate(
//                 offset: Offset(50 * (1 - value), 0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Column(
//                       children: [
//                         AnimatedContainer(
//                           duration: Duration(milliseconds: 500),
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: isCurrent ? currentColor : stepColor,
//                             shape: BoxShape.circle,
//                             boxShadow: isCurrent ? [
//                               BoxShadow(
//                                 color: currentColor.withOpacity(0.4),
//                                 blurRadius: 10,
//                                 spreadRadius: 2,
//                               ),
//                             ] : [],
//                           ),
//                           child: AnimatedSwitcher(
//                             duration: Duration(milliseconds: 300),
//                             child: Icon(
//                               isCompleted ? Icons.check : step['icon'],
//                               key: ValueKey(isCompleted),
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),
//                         ),
//                         if (!isLast)
//                           AnimatedContainer(
//                             duration: Duration(milliseconds: 500),
//                             width: 2,
//                             height: 40,
//                             color: isCompleted ? Colors.green[600] : Colors.grey[300],
//                             margin: EdgeInsets.symmetric(vertical: 8),
//                           ),
//                       ],
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             step['status'],
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: isCompleted ? Colors.grey[800] : Colors.grey[500],
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             step['description'],
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 14,
//                             ),
//                           ),
//                           if (isCurrent) ...[
//                             SizedBox(height: 8),
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue[50],
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 'Current Status',
//                                 style: TextStyle(
//                                   color: Colors.blue[600],
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                           SizedBox(height: 16),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildEstimatedDelivery() {
//     DateTime estimatedDate = widget.order.isNotEmpty && widget.order.first.deliveryDate != null
//         ? widget.order.first.deliveryDate!
//         : DateTime.now().add(Duration(days: 3));
//
//     return Container(
//       margin: EdgeInsets.all(16),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.orange[400]!, Colors.orange[400]!],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.orange.withOpacity(0.3),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               Icons.local_shipping,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Estimated Delivery',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 14,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   _formatDate(estimatedDate),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               _getDaysRemaining(estimatedDate),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDeliveryAddress() {
//     if (_userInfo == null) return SizedBox();
//
//     return Container(
//       margin: EdgeInsets.all(16),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.location_on, color: Colors.red[400]),
//               SizedBox(width: 8),
//               Text(
//                 'Delivery Address',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[800],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           if (_selectedArea != null) ...[
//             Text(
//               'Area: ${_selectedArea!.area}',
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey[700],
//               ),
//             ),
//             SizedBox(height: 8),
//           ],
//           Text(
//             _userInfo!.deliveryAddress,
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 16,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Phone: ${_userInfo!.phone}',
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatusHistory() {
//     if (_statusHistory.isEmpty) return SizedBox();
//
//     return Container(
//       margin: EdgeInsets.all(16),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Status Updates',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           SizedBox(height: 16),
//           ...List.generate(_statusHistory.length, (index) {
//             final history = _statusHistory[index];
//             return TweenAnimationBuilder<double>(
//               duration: Duration(milliseconds: 600 + (index * 100)),
//               tween: Tween(begin: 0.0, end: 1.0),
//               builder: (context, value, child) {
//                 return Transform.translate(
//                   offset: Offset(30 * (1 - value), 0),
//                   child: Opacity(
//                     opacity: value,
//                     child: Container(
//                       margin: EdgeInsets.only(bottom: 12),
//                       padding: EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border(
//                           left: BorderSide(
//                             color: Colors.blue[600]!,
//                             width: 4,
//                           ),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 history.status,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue[600],
//                                 ),
//                               ),
//                               Spacer(),
//                               Text(
//                                 _formatDateTime(history.timestamp),
//                                 style: TextStyle(
//                                   color: Colors.grey[500],
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             history.message,
//                             style: TextStyle(color: Colors.grey[700]),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFloatingActions() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         FloatingActionButton(
//           heroTag: "refresh",
//           onPressed: () {
//             _loadTrackingData();
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Successfully! Tracking information refreshed '),
//                 backgroundColor: Colors.black,
//               ),
//             );
//           },
//           backgroundColor: Colors.blue[600],
//           child: Icon(Icons.refresh, color: Colors.white),
//         ),
//         SizedBox(height: 16),
//         FloatingActionButton.extended(
//           heroTag: "support",
//           onPressed: () {
//             // TODO: Implement customer support
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('customer support coming soon!'),
//                 backgroundColor: Colors.orange[400],
//               ),
//             );
//           },
//           backgroundColor: Colors.orange[400],
//           icon: Icon(Icons.support_agent, color: Colors.white),
//           label: Text(
//             'Support',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _formatDateTime(DateTime date) {
//     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//   }
//
//   String _getDaysRemaining(DateTime deliveryDate) {
//     int days = deliveryDate.difference(DateTime.now()).inDays;
//     if (days < 0) return 'Overdue';
//     if (days == 0) return 'Today';
//     if (days == 1) return 'Tomorrow';
//     return '$days days';
//   }
//
//   @override
//   void dispose() {
//     _progressAnimationController.dispose();
//     _pulseAnimationController.dispose();
//     super.dispose();
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/ProductModel.dart';
import 'package:project/screen/model/order_tracker_model.dart';
import 'package:project/screen/model/orders_model.dart';
import 'package:project/screen/model/selected_area_model.dart';
import 'package:project/screen/model/status_history_model.dart';
import 'package:project/screen/model/user_info_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final List<OrdersModel> order; // This is a list
  const OrderTrackingScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  OrderTrackerModel? _orderTracker;
  List<StatusHistoryModel> _statusHistory = [];
  List<ProductModel> _products = []; // Changed to list for multiple products
  UserInfoModel? _userInfo;
  SelectedAreaModel? _selectedArea;
  bool _isLoading = true;

  // Calculate totals from the order list
  double get _totalAmount => widget.order.fold(0.0, (sum, order) => sum + order.totalAmount);
  String get _orderId => widget.order.isNotEmpty ? widget.order.first.orderId : '';
  String get _orderStatus => widget.order.isNotEmpty ? widget.order.first.orderStatus : '';
  DateTime get _orderDate => widget.order.isNotEmpty ? widget.order.first.orderDate : DateTime.now();
  String get _userId => widget.order.isNotEmpty ? widget.order.first.userId : '';

  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _trackingSteps = [
    {
      'status': 'Order Placed',
      'icon': Icons.shopping_cart,
      'description': 'Your order has been placed successfully',
    },
    {
      'status': 'Approved',
      'icon': Icons.verified,
      'description': 'Order confirmed and being prepared',
    },
    {
      'status': 'Processing',
      'icon': Icons.settings,
      'description': 'Your order is being processed',
    },
    {
      'status': 'Shipped',
      'icon': Icons.local_shipping,
      'description': 'Order has been shipped',
    },
    {
      'status': 'Out for Delivery',
      'icon': Icons.delivery_dining,
      'description': 'Order is out for delivery',
    },
    {
      'status': 'Delivered',
      'icon': Icons.check_circle,
      'description': 'Order delivered successfully',
    },
  ];

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseAnimationController, curve: Curves.elasticInOut),
    );

    _pulseAnimationController.repeat(reverse: true);
    _loadTrackingData();
  }

  Future<void> _loadTrackingData() async {
    try {
      if (widget.order.isEmpty) return;

      // Load order tracker using the first order's orderId (since all have same orderId)
      QuerySnapshot trackerQuery = await FirebaseFirestore.instance
          .collection('OrderTracker')
          .where('orderId', isEqualTo: _orderId)
          .limit(1)
          .get();

      if (trackerQuery.docs.isNotEmpty) {
        _orderTracker = OrderTrackerModel.fromSnapshot(trackerQuery.docs.first);
      }

      // Load status history
      QuerySnapshot historyQuery = await FirebaseFirestore.instance
          .collection('StatusHistory')
          .where('orderId', isEqualTo: _orderId)
          .orderBy('timestamp', descending: false)
          .get();

      _statusHistory = StatusHistoryModel.fromQuerySnapshot(historyQuery);

      // Load product details for ALL products in the order
      List<ProductModel> loadedProducts = [];
      for (OrdersModel orderItem in widget.order) {
        try {
          DocumentSnapshot productDoc = await FirebaseFirestore.instance
              .collection('Books')
              .doc(orderItem.productId)
              .get();

          if (productDoc.exists) {
            ProductModel product = ProductModel.fromSnapshot(productDoc);
            loadedProducts.add(product);
          }
        } catch (e) {
          print('Error loading product ${orderItem.productId}: $e');
        }
      }
      _products = loadedProducts;

      // Load user info
      QuerySnapshot userInfoQuery = await FirebaseFirestore.instance
          .collection('UserInfo')
          .where('userId', isEqualTo: _userId)
          .orderBy('FieldValue.serverTimestamp()', descending: true)
          .limit(1)
          .get();

      if (userInfoQuery.docs.isNotEmpty) {
        _userInfo = UserInfoModel.fromSnapshot(userInfoQuery.docs.first);

        // Load selected area
        if (_userInfo!.selectedAreaId.isNotEmpty) {
          DocumentSnapshot areaDoc = await FirebaseFirestore.instance
              .collection('SelectedArea')
              .doc(_userInfo!.selectedAreaId)
              .get();

          if (areaDoc.exists) {
            _selectedArea = SelectedAreaModel.fromSnapshot(areaDoc);
          }
        }
      }

      _progressAnimationController.forward();
    } catch (e) {
      print('Error loading tracking data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading tracking data: $e'),
          backgroundColor: Colors.red[400],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _getCurrentStepIndex() {
    String currentStatus = _orderStatus;
    for (int i = 0; i < _trackingSteps.length; i++) {
      if (_trackingSteps[i]['status'].toString().toLowerCase() ==
          currentStatus.toLowerCase()) {
        return i;
      }
    }
    return 0;
  }

  Future<int> getCartDocument(String cartId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Cart')
          .doc(cartId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int quantity = data['quantity'];
        print("Quantity in function $quantity");
        return quantity;
      } else {
        print('No such cart document found');
        return 0;
      }
    } catch (e) {
      print('Error fetching cart document: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? _buildLoadingState()
          : CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildOrderSummary(),
                _buildTrackingProgress(),
                _buildEstimatedDelivery(),
                _buildProductDetails(), // This will now show all products
                _buildDeliveryAddress(),
                _buildStatusHistory(),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(),
    );
  }

  // Updated Order Summary to show combined totals
  Widget _buildOrderSummary() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID and Status
          Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Order #$_orderId',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Flexible(
                flex: 2,
                child: _buildAnimatedStatusChip(_orderStatus),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Date, Items Count, and Total Price
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                        SizedBox(width: 8),
                        Text(
                          'Ordered on ${_formatDate(_orderDate)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.shopping_bag, size: 16, color: Colors.grey[500]),
                        SizedBox(width: 8),
                        Text(
                          '${widget.order.length} item(s)',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '\$${_totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Updated Product Details to show all products
  Widget _buildProductDetails() {
    if (_products.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${widget.order.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          // List all products
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.order.length,
            separatorBuilder: (context, index) => Divider(height: 24),
            itemBuilder: (context, index) {
              OrdersModel orderItem = widget.order[index];
              ProductModel? product = _products.length > index ? _products[index] : null;

              return _buildProductItem(orderItem, product);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrdersModel orderItem, ProductModel? product) {
    String? cartid = orderItem.cartId;
    print("cartid $cartid");

    return FutureBuilder<int>(
      future: getCartDocument(cartid!),
      builder: (context, snapshot) {
        int quantity = snapshot.data ?? 0;

        return Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product != null
                  ? Image(
                image: MemoryImage(base64Decode(product.imgurl)),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 30),
                ),
              )
                  : Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 30),
              ),
            ),
            SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.name ?? 'Product Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$${orderItem.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                      fontSize: 14,
                    ),
                  ),
                  snapshot.connectionState == ConnectionState.waiting
                      ? Text("Loading qty...")
                      : Text("Quantity: $quantity"),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black!),
            ),
            SizedBox(height: 16),
            Text(
              'Loading tracking information...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 150,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Track Your Order',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black!, Colors.black54!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    Icons.track_changes,
                    size: 50,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatusChip(String status) {
    Color borderColor;
    Color backgroundColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        borderColor = Color(0xFFF59E0B);
        backgroundColor = Colors.white;
        icon = Icons.pending_outlined;
        break;
      case 'order placed':
        borderColor = Color(0xFF3B82F6);
        backgroundColor = Colors.white;
        icon = Icons.shopping_bag_outlined;
        break;
      case 'approved':
        borderColor = Color(0xFF10B981);
        backgroundColor = Color(0xFFD1FAE5);
        icon = Icons.check_circle_outline;
        break;
      case 'processing':
        borderColor = Color(0xFF8B5CF6);
        backgroundColor = Color(0xFFEDE9FE);
        icon = Icons.settings_outlined;
        break;
      case 'shipped':
        borderColor = Color(0xFF6366F1);
        backgroundColor = Color(0xFFE0E7FF);
        icon = Icons.local_shipping_outlined;
        break;
      case 'out for delivery':
        borderColor = Color(0xFF06B6D4);
        backgroundColor = Color(0xFFCFFAFE);
        icon = Icons.delivery_dining_outlined;
        break;
      case 'delivered':
        borderColor = Color(0xFF059669);
        backgroundColor = Color(0xFFD1FAE5);
        icon = Icons.check_circle_outline;
        break;
      default:
        borderColor = Color(0xFF6B7280);
        backgroundColor = Color(0xFFF3F4F6);
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
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: borderColor),
                SizedBox(width: 4),
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

  // Keep all other existing methods unchanged...
  Widget _buildTrackingProgress() {
    int currentStep = _getCurrentStepIndex();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          ...List.generate(_trackingSteps.length, (index) {
            bool isCompleted = index <= currentStep;
            bool isCurrent = index == currentStep;
            bool isLast = index == _trackingSteps.length - 1;

            return _buildTrackingStep(
              _trackingSteps[index],
              isCompleted,
              isCurrent,
              isLast,
              index,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(
      Map<String, dynamic> step,
      bool isCompleted,
      bool isCurrent,
      bool isLast,
      int index,
      ) {
    Color stepColor = isCompleted ? Colors.green[600]! : Colors.grey[300]!;
    Color currentColor = isCurrent ? Colors.blue[600]! : stepColor;

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        double animationValue = _progressAnimation.value;
        if (index > _getCurrentStepIndex()) {
          animationValue = 0.0;
        }

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 800 + (index * 200)),
          tween: Tween(begin: 0.0, end: animationValue),
          builder: (context, value, child) {
            return Opacity(
              opacity: 0.3 + (0.7 * value),
              child: Transform.translate(
                offset: Offset(50 * (1 - value), 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCurrent ? currentColor : stepColor,
                            shape: BoxShape.circle,
                            boxShadow: isCurrent ? [
                              BoxShadow(
                                color: currentColor.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ] : [],
                          ),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: Icon(
                              isCompleted ? Icons.check : step['icon'],
                              key: ValueKey(isCompleted),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        if (!isLast)
                          AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            width: 2,
                            height: 40,
                            color: isCompleted ? Colors.green[600] : Colors.grey[300],
                            margin: EdgeInsets.symmetric(vertical: 8),
                          ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['status'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isCompleted ? Colors.grey[800] : Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            step['description'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          if (isCurrent) ...[
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Current Status',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEstimatedDelivery() {
    DateTime estimatedDate = widget.order.isNotEmpty && widget.order.first.deliveryDate != null
        ? widget.order.first.deliveryDate!
        : DateTime.now().add(Duration(days: 3));

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.orange[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Delivery',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatDate(estimatedDate),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getDaysRemaining(estimatedDate),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    if (_userInfo == null) return SizedBox();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red[400]),
              SizedBox(width: 8),
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_selectedArea != null) ...[
            Text(
              'Area: ${_selectedArea!.area}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
          ],
          Text(
            _userInfo!.deliveryAddress,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Phone: ${_userInfo!.phone}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHistory() {
    if (_statusHistory.isEmpty) return SizedBox();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Updates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          ...List.generate(_statusHistory.length, (index) {
            final history = _statusHistory[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 600 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(30 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: Colors.blue[600]!,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                history.status,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              ),
                              Spacer(),
                              Text(
                                _formatDateTime(history.timestamp),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            history.message,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "refresh",
          onPressed: () {
            _loadTrackingData();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully! Tracking information refreshed '),
                backgroundColor: Colors.black,
              ),
            );
          },
          backgroundColor: Colors.blue[600],
          child: Icon(Icons.refresh, color: Colors.white),
        ),
        SizedBox(height: 16),
        FloatingActionButton.extended(
          heroTag: "support",
          onPressed: () {
            // TODO: Implement customer support
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('customer support coming soon!'),
                backgroundColor: Colors.orange[400],
              ),
            );
          },
          backgroundColor: Colors.orange[400],
          icon: Icon(Icons.support_agent, color: Colors.white),
          label: Text(
            'Support',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getDaysRemaining(DateTime deliveryDate) {
    int days = deliveryDate.difference(DateTime.now()).inDays;
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    return '$days days';
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }
}