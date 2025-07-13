// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../model/ProductModel.dart';
// import '../../model/Users.dart';
// import '../../model/orders_model.dart';
// import '../UsersList/purchase_history_table.dart';
//
//
// class UserDetailsScreen extends StatefulWidget {
//   final UsersModel user;
//
//   const UserDetailsScreen({Key? key, required this.user}) : super(key: key);
//
//   @override
//   State<UserDetailsScreen> createState() => _UserDetailsScreenState();
// }
//
// class _UserDetailsScreenState extends State<UserDetailsScreen> {
//   List<OrderWithProduct> userOrders = [];
//   bool isLoading = true;
//   double totalOrderValue = 0.0;
//   int totalOrdersCount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserOrders();
//   }
//
//   Future<void> _loadUserOrders() async {
//     try {
//       // Get delivered orders for this user
//       final ordersSnapshot = await FirebaseFirestore.instance
//           .collection('Orders')
//           .where('userId', isEqualTo: widget.user.id)
//           .where('orderStatus', isEqualTo: 'Delivered')
//           .orderBy('orderDate', descending: true)
//           .get();
//
//       List<OrderWithProduct> ordersWithProducts = [];
//       double totalValue = 0.0;
//
//       for (var orderDoc in ordersSnapshot.docs) {
//         final order = OrdersModel.fromSnapshot(orderDoc);
//
//         // Get product details
//         final productDoc = await FirebaseFirestore.instance
//             .collection('Books') // Assuming products are in 'Books' collection
//             .doc(order.productId)
//             .get();
//
//         if (productDoc.exists) {
//           final product = ProductModel.fromSnapshot(productDoc);
//           ordersWithProducts.add(OrderWithProduct(order: order, product: product));
//           totalValue += order.totalAmount;
//         }
//       }
//
//       setState(() {
//         userOrders = ordersWithProducts;
//         totalOrderValue = totalValue;
//         totalOrdersCount = ordersWithProducts.length;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading orders: $e');
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading orders: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           widget.user.userName,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.blue[600],
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Colors.blue),
//             )
//           : SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//
//                   CustomScrollView(
//                     slivers: [
//                       // App Bar with User Profile
//
//
//                       // User Details and Purchase History
//                       SliverToBoxAdapter(
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // User Information Card
//                               Card(
//                                 color: Colors.white,
//                                 elevation: 2,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(20),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       const Text(
//                                         'User Information',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 16),
//
//                                       _buildInfoRow('User ID', widget.user.id ?? 'N/A'),
//                                       _buildInfoRow('Username', widget.user.userName),
//                                       _buildInfoRow('Email', widget.user.email),
//                                       _buildInfoRow('Role', widget.user.role),
//                                       if (widget.user.createdAt != null)
//                                         _buildInfoRow(
//                                             'Member Since',
//                                             '${widget.user.createdAt!.day}/${widget.user.createdAt!.month}/${widget.user.createdAt!.year}'
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 24),
//
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//
//
//
//
//
//                   _buildUserDetailsCard(),
//                   _buildOrdersStatsCard(),
//                   _buildOrdersHistorySection(),
//                 ],
//               ),
//             ),
//     );
//   }
//
//
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.black87,
//               ),
//             ),
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
//   Widget _buildUserDetailsCard() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Profile Picture
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.blue[600]!, width: 4),
//             ),
//             child: CircleAvatar(
//               radius: 46,
//               backgroundColor: Colors.blue[100],
//               backgroundImage: widget.user.profile != null
//                   ? MemoryImage(base64Decode(widget.user.profile!))
//                   : null,
//
//
//
//               child: widget.user.profile == null || widget.user.profile!.isEmpty
//                   ? Icon(Icons.person, size: 50, color: Colors.blue[600])
//                   : null,
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // User Info
//           Text(
//             widget.user.userName,
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.blue[600],
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               widget.user.role,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Contact Info
//           _buildInfoRows(Icons.email, 'Email', widget.user.email),
//           const SizedBox(height: 8),
//           _buildInfoRows(Icons.calendar_today, 'Joined',
//               widget.user.createdAt?.toString().split(' ')[0] ?? 'N/A'),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRows(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: Colors.blue[600]),
//         const SizedBox(width: 12),
//         Text(
//           '$label: ',
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             color: Colors.grey,
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(
//               color: Colors.black87,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOrdersStatsCard() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue[600]!, Colors.blue[400]!],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               children: [
//                 const Text(
//                   'Total Orders',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '$totalOrdersCount',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 1,
//             height: 40,
//             color: Colors.white30,
//           ),
//           Expanded(
//             child: Column(
//               children: [
//                 const Text(
//                   'Total Spent',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '\$${totalOrderValue.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrdersHistorySection() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Order History',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           if (userOrders.isEmpty)
//             Container(
//               padding: const EdgeInsets.all(40),
//               child: const Center(
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.shopping_bag_outlined,
//                       size: 64,
//                       color: Colors.grey,
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'No delivered orders found',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: userOrders.length,
//               itemBuilder: (context, index) {
//                 return _buildOrderCard(userOrders[index]);
//               },
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrderCard(OrderWithProduct orderWithProduct) {
//     final order = orderWithProduct.order;
//     final product = orderWithProduct.product;
//     String fullId = order.orderId;
//     String shortId = fullId.length > 10 ? fullId.substring(0, 10) : fullId;
//
//
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Order Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Order #${order.orderId}'),
//                         duration: Duration(seconds: 5), // Automatically hides after 5 seconds
//                         behavior: SnackBarBehavior.floating,
//                         backgroundColor: Colors.black,
//                       ),
//                     );
//                   },
//                   child: Text(
//                     'Order #$shortId',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.green[100],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     order.orderStatus,
//                     style: TextStyle(
//                       color: Colors.green[700],
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             // Product Details
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Product Image
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: Colors.grey[200],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: product.imgurl.isNotEmpty
//                         ? Image.memory(
//                       base64Decode(product.imgurl!),
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Icon(
//                                 Icons.image_not_supported,
//                                 color: Colors.grey[400],
//                                 size: 40,
//                               );
//                             },
//                           )
//                         : Icon(
//                             Icons.image_not_supported,
//                             color: Colors.grey[400],
//                             size: 40,
//                           ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//
//                 // Product Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         product.name,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Category: ${product.categoryid ?? 'N/A'}',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 12,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Text(
//                             'Price: \$${product.price.toStringAsFixed(2)}',
//                             style: TextStyle(
//                               color: Colors.blue[600],
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Text(
//                             'Qty: ${(order.totalAmount / product.price).round()}',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             // Order Summary
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text('Order Date:'),
//                       Text(
//                         order.orderDate.toString().split(' ')[0],
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text('Payment Method:'),
//                       Text(
//                         order.paymentMethod,
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                     ],
//                   ),
//                   const Divider(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Total Amount:',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       Text(
//                         '\$${order.totalAmount.toStringAsFixed(2)}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Colors.blue[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Helper class to combine order and product data
// class OrderWithProduct {
//   final OrdersModel order;
//   final ProductModel product;
//
//   OrderWithProduct({required this.order, required this.product});
// }









import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/ProductModel.dart';
import '../../model/Users.dart';
import '../../model/orders_model.dart';
import '../UsersList/purchase_history_table.dart';

class UserDetailsScreen extends StatefulWidget {
  final UsersModel user;

  const UserDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  List<OrderWithProduct> userOrders = [];
  bool isLoading = true;
  double totalOrderValue = 0.0;
  int totalOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  Future<void> _loadUserOrders() async {
    try {
      // Get delivered orders for this user
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('userId', isEqualTo: widget.user.id)
          .where('orderStatus', isEqualTo: 'Delivered')
          .orderBy('orderDate', descending: true)
          .get();

      List<OrderWithProduct> ordersWithProducts = [];
      double totalValue = 0.0;

      for (var orderDoc in ordersSnapshot.docs) {
        final order = OrdersModel.fromSnapshot(orderDoc);

        // Get product details
        final productDoc = await FirebaseFirestore.instance
            .collection('Books') // Assuming products are in 'Books' collection
            .doc(order.productId)
            .get();

        if (productDoc.exists) {
          final product = ProductModel.fromSnapshot(productDoc);
          ordersWithProducts.add(OrderWithProduct(order: order, product: product));
          totalValue += order.totalAmount;
        }
      }

      setState(() {
        userOrders = ordersWithProducts;
        totalOrderValue = totalValue;
        totalOrdersCount = ordersWithProducts.length;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.user.userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserDetailsCard(),
            _buildUserInfoCard(),
            _buildOrdersStatsCard(),
            _buildOrdersHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('User ID', widget.user.id ?? 'N/A'),
            _buildInfoRow('Username', widget.user.userName),
            _buildInfoRow('Email', widget.user.email),
            _buildInfoRow('Role', widget.user.role),
            if (widget.user.createdAt != null)
              _buildInfoRow(
                  'Member Since',
                  '${widget.user.createdAt!.day}/${widget.user.createdAt!.month}/${widget.user.createdAt!.year}'
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue[600]!, width: 4),
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: Colors.blue[100],
              backgroundImage: _getProfileImage(),
              child: _getProfileImage() == null
                  ? Icon(Icons.person, size: 50, color: Colors.blue[600])
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // User Info
          Text(
            widget.user.userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.user.role,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contact Info
          _buildInfoRows(Icons.email, 'Email', widget.user.email),
          const SizedBox(height: 8),
          _buildInfoRows(Icons.calendar_today, 'Joined',
              widget.user.createdAt?.toString().split(' ')[0] ?? 'N/A'),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    try {
      if (widget.user.profile != null && widget.user.profile!.isNotEmpty) {
        // Try to decode as base64 first
        try {
          final bytes = base64Decode(widget.user.profile!);
          return MemoryImage(bytes);
        } catch (e) {
          // If base64 decode fails, try as network image
          if (widget.user.profile!.startsWith('http')) {
            return NetworkImage(widget.user.profile!);
          }
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
    return null;
  }

  Widget _buildInfoRows(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Total Orders',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalOrdersCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white30,
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Total Spent',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${totalOrderValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersHistorySection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          if (userOrders.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No delivered orders found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userOrders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(userOrders[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderWithProduct orderWithProduct) {
    final order = orderWithProduct.order;
    final product = orderWithProduct.product;
    String fullId = order.orderId;
    String shortId = fullId.length > 10 ? fullId.substring(0, 10) : fullId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order #${order.orderId}'),
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.black87,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Order #$shortId',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.orderStatus,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildProductImage(product),
                  ),
                ),
                const SizedBox(width: 16),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${product.categoryid ?? 'N/A'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Text(
                            'Price: \$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Qty: ${_calculateQuantity(order.totalAmount, product.price)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Order Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order Date:'),
                      Text(
                        _formatDate(order.orderDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payment Method:'),
                      Text(
                        order.paymentMethod,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductModel product) {
    try {
      if (product.imgurl.isNotEmpty) {
        // Try to decode as base64 first
        try {
          final bytes = base64Decode(product.imgurl);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          );
        } catch (e) {
          // If base64 decode fails, try as network image
          if (product.imgurl.startsWith('http')) {
            return Image.network(
              product.imgurl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();
              },
            );
          }
        }
      }
    } catch (e) {
      print('Error loading product image: $e');
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Icon(
      Icons.image_not_supported,
      color: Colors.grey[400],
      size: 40,
    );
  }

  int _calculateQuantity(double totalAmount, double price) {
    if (price <= 0) return 0;
    return (totalAmount / price).round();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Helper class to combine order and product data
class OrderWithProduct {
  final OrdersModel order;
  final ProductModel product;

  OrderWithProduct({required this.order, required this.product});
}