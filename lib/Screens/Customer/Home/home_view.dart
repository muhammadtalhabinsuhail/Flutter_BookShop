// // import 'dart:convert';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:project/Screens/Customer/Home/profile_avatar_widget.dart';
// //
// // import '../../Models/ProductModel.dart';
// // import '../Cart/cart_controller.dart';
// // import '../Cart/cart_screen.dart';
// // import 'add_to_cart_button.dart';
// // import 'home_controller.dart';
// //
// //
// // class CategoryModel {
// //   final String id;
// //   final String categoriesname;
// //
// //   CategoryModel({required this.id, required this.categoriesname});
// // }
// //
// // class Home extends StatefulWidget {
// //   const Home({super.key});
// //
// //   @override
// //   State<Home> createState() => _HomeState();
// // }
// //
// // class _HomeState extends State<Home> {
// //   int _selectedIndex = 0;
// //   int _cartItemsCount = 0;
// //
// //   final HomeController _controller = HomeController();
// //   final CartController _cartController = CartController();
// //   late Future<List<ProductModel>> _futureProducts;
// //   late Future<List<CategoryModel>> _futureCategories;
// //
// //   Map<String, List<ProductModel>> _productsByCategory = {};
// //   Map<String, bool> _expandedCategories = {};
// //   Map<String, String> _categoryNames = {};
// //   bool _isDataInitialized = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _futureProducts = _controller.getAllProducts();
// //     _futureCategories = _fetchCategories();
// //     _initializeData();
// //     _updateCartCount();
// //   }
// //
// //   Future<void> _initializeData() async {
// //     try {
// //       final products = await _futureProducts;
// //       final categories = await _futureCategories;
// //
// //       for (var category in categories) {
// //         _categoryNames[category.id] = category.categoriesname;
// //         _expandedCategories[category.id] = false;
// //       }
// //
// //       _productsByCategory.clear();
// //       for (var product in products) {
// //         if (product.categoryid != null && product.categoryid!.isNotEmpty) {
// //           if (_productsByCategory[product.categoryid] == null) {
// //             _productsByCategory[product.categoryid!] = [];
// //           }
// //           _productsByCategory[product.categoryid]!.add(product);
// //
// //           if (!_expandedCategories.containsKey(product.categoryid)) {
// //             _expandedCategories[product.categoryid!] = false;
// //           }
// //         }
// //       }
// //
// //       setState(() {
// //         _isDataInitialized = true;
// //       });
// //     } catch (e) {
// //       print('Error initializing data: $e');
// //       setState(() {
// //         _isDataInitialized = true;
// //       });
// //     }
// //   }
// //
// //   Future<List<CategoryModel>> _fetchCategories() async {
// //     try {
// //       QuerySnapshot snapshot = await FirebaseFirestore.instance
// //           .collection('categories')
// //           .get();
// //
// //       return snapshot.docs.map((doc) => CategoryModel(
// //         id: doc.id,
// //         categoriesname: doc['categoriesname'] ?? '',
// //       )).toList();
// //     } catch (e) {
// //       print('Error fetching categories: $e');
// //       return [];
// //     }
// //   }
// //
// //   Future<void> _updateCartCount() async {
// //     try {
// //       int count = await _cartController.getCartCount();
// //       if (mounted) {
// //         setState(() {
// //           _cartItemsCount = count;
// //         });
// //       }
// //     } catch (e) {
// //       print('Error updating cart count: $e');
// //     }
// //   }
// //
// //   void _toggleCategoryExpansion(String categoryId) {
// //     setState(() {
// //       _expandedCategories[categoryId] = !(_expandedCategories[categoryId] ?? false);
// //     });
// //   }
// //
// //   void _showProductDetails(ProductModel product) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (context) => _buildProductDetailsSheet(product),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             Container(
// //               color: Colors.white,
// //               padding: const EdgeInsets.all(20.0),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       const Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'Buy your',
// //                             style: TextStyle(
// //                               fontSize: 28,
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.black,
// //                             ),
// //                           ),
// //                           Text(
// //                             'favorite gadget',
// //                             style: TextStyle(
// //                               fontSize: 16,
// //                               color: Colors.grey,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       ProfileAvatarWidget(
// //                         onLoginRequired: () {
// //                           // Handle login navigation
// //                         },
// //                         onLogoutSuccess: () {
// //                           _updateCartCount();
// //                         },
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 24),
// //                   Container(
// //                     height: 50,
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[100],
// //                       borderRadius: BorderRadius.circular(25),
// //                     ),
// //                     child: TextField(
// //                       decoration: InputDecoration(
// //                         hintText: 'Search gadgets',
// //                         hintStyle: TextStyle(color: Colors.grey[500]),
// //                         prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
// //                         border: InputBorder.none,
// //                         contentPadding: const EdgeInsets.symmetric(
// //                           horizontal: 20,
// //                           vertical: 15,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Expanded(
// //               child: _isDataInitialized
// //                   ? (_productsByCategory.isEmpty
// //                       ? const Center(child: Text('No products found'))
// //                       : SingleChildScrollView(
// //                           padding: const EdgeInsets.symmetric(horizontal: 20),
// //                           child: Column(
// //                             children: _buildCategoryWidgets(),
// //                           ),
// //                         ))
// //                   : const Center(child: CircularProgressIndicator()),
// //             ),
// //           ],
// //         ),
// //       ),
// //       bottomNavigationBar: BottomNavigationBar(
// //         currentIndex: _selectedIndex,
// //         onTap: (index) {
// //           setState(() {
// //             _selectedIndex = index;
// //           });
// //
// //           switch (index) {
// //             case 0:
// //               // Already on Home
// //               break;
// //             case 1:
// //               // Navigate to Top Trends
// //               break;
// //             case 2:
// //               Navigator.push(
// //                 context,
// //                 MaterialPageRoute(builder: (context) => const CartScreen()),
// //               );
// //               break;
// //             case 3:
// //               // Navigate to Saved
// //               break;
// //             case 4:
// //               // Navigate to Profile
// //               break;
// //           }
// //         },
// //         type: BottomNavigationBarType.fixed,
// //         selectedItemColor: Colors.black,
// //         unselectedItemColor: Colors.grey,
// //         showSelectedLabels: true,
// //         showUnselectedLabels: true,
// //         items: [
// //           const BottomNavigationBarItem(
// //             icon: Icon(Icons.home_outlined),
// //             activeIcon: Icon(Icons.home, color: Colors.black),
// //             label: 'Home',
// //           ),
// //           const BottomNavigationBarItem(
// //             icon: Icon(Icons.shopping_bag_outlined),
// //             label: 'Top Trends',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Stack(
// //               children: [
// //                 const Icon(Icons.shopping_cart_outlined),
// //                 if (_cartItemsCount > 0)
// //                   Positioned(
// //                     right: 0,
// //                     top: 0,
// //                     child: Container(
// //                       padding: const EdgeInsets.all(2),
// //                       decoration: BoxDecoration(
// //                         color: Colors.red.shade400,
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                       constraints: const BoxConstraints(
// //                         minWidth: 16,
// //                         minHeight: 16,
// //                       ),
// //                       child: Text(
// //                         '$_cartItemsCount',
// //                         style: const TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 10,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //             activeIcon: Stack(
// //               children: [
// //                 const Icon(Icons.shopping_cart),
// //                 if (_cartItemsCount > 0)
// //                   Positioned(
// //                     right: 0,
// //                     top: 0,
// //                     child: Container(
// //                       padding: const EdgeInsets.all(2),
// //                       decoration: BoxDecoration(
// //                         color: Colors.red,
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                       constraints: const BoxConstraints(
// //                         minWidth: 16,
// //                         minHeight: 16,
// //                       ),
// //                       child: Text(
// //                         '$_cartItemsCount',
// //                         style: const TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 10,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //             label: 'Cart',
// //           ),
// //           const BottomNavigationBarItem(
// //             icon: Icon(Icons.bookmark_outline),
// //             activeIcon: Icon(Icons.bookmark),
// //             label: 'Saved',
// //           ),
// //           const BottomNavigationBarItem(
// //             icon: Icon(Icons.person_outline),
// //             activeIcon: Icon(Icons.person),
// //             label: 'Profile',
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   List<Widget> _buildCategoryWidgets() {
// //     List<Widget> categoryWidgets = [];
// //     List<String> allCategoryIds = _categoryNames.keys.toList();
// //
// //     for (int i = 0; i < allCategoryIds.length; i++) {
// //       String categoryId = allCategoryIds[i];
// //       String categoryName = _categoryNames[categoryId] ?? 'Unknown Category';
// //       List<ProductModel> products = _productsByCategory[categoryId] ?? [];
// //       bool isExpanded = _expandedCategories[categoryId] ?? false;
// //
// //       categoryWidgets.add(
// //         Padding(
// //           padding: const EdgeInsets.only(top: 24, bottom: 16),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Expanded(
// //                 child: Text(
// //                   categoryName,
// //                   style: const TextStyle(
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.black,
// //                   ),
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //               if (products.isNotEmpty)
// //                 GestureDetector(
// //                   onTap: () => _toggleCategoryExpansion(categoryId),
// //                   child: Container(
// //                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                     child: Text(
// //                       isExpanded ? 'Close All' : 'See all',
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         color: isExpanded ? Colors.red : Colors.grey[600],
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       );
// //
// //       if (products.isNotEmpty) {
// //         List<ProductModel> displayProducts = isExpanded
// //             ? products
// //             : products.take(2).toList();
// //
// //         categoryWidgets.add(
// //           GridView.builder(
// //             shrinkWrap: true,
// //             physics: const NeverScrollableScrollPhysics(),
// //             padding: const EdgeInsets.only(bottom: 16),
// //             itemCount: displayProducts.length,
// //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //               crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
// //               crossAxisSpacing: 12,
// //               mainAxisSpacing: 16,
// //               childAspectRatio: 0.54,
// //             ),
// //             itemBuilder: (context, index) {
// //               return _buildProductCard(displayProducts[index]);
// //             },
// //           ),
// //         );
// //       } else {
// //         categoryWidgets.add(
// //           Padding(
// //             padding: const EdgeInsets.only(bottom: 24),
// //             child: Container(
// //               height: 100,
// //               decoration: BoxDecoration(
// //                 color: Colors.grey[100],
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: Colors.grey[300]!),
// //               ),
// //               child: Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Icon(Icons.inventory_2_outlined,
// //                         color: Colors.grey[400], size: 32),
// //                     const SizedBox(height: 8),
// //                     Text(
// //                       'No products in this category',
// //                       style: TextStyle(
// //                         color: Colors.grey[600],
// //                         fontSize: 14,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         );
// //       }
// //     }
// //
// //     return categoryWidgets;
// //   }
// //
// //   Widget _buildProductCard(ProductModel product) {
// //     return GestureDetector(
// //       onTap: () => _showProductDetails(product),
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(16),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.grey.withOpacity(0.1),
// //               spreadRadius: 1,
// //               blurRadius: 10,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Expanded(
// //               flex: 3,
// //               child: Container(
// //                 width: double.infinity,
// //                 decoration: BoxDecoration(
// //                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
// //                   color: Colors.grey[100],
// //                 ),
// //                 child: Stack(
// //                   children: [
// //                     ClipRRect(
// //                       borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
// //                       child: Image.memory(
// //                         base64Decode(product.imgurl),
// //                         width: double.infinity,
// //                         height: double.infinity,
// //                         fit: BoxFit.cover,
// //                         errorBuilder: (context, error, stackTrace) {
// //                           return Container(
// //                             width: double.infinity,
// //                             height: double.infinity,
// //                             decoration: BoxDecoration(
// //                               gradient: LinearGradient(
// //                                 begin: Alignment.topLeft,
// //                                 end: Alignment.bottomRight,
// //                                 colors: [
// //                                   Colors.orange.shade300,
// //                                   Colors.orange.shade600,
// //                                 ],
// //                               ),
// //                               borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
// //                             ),
// //                             child: const Icon(
// //                               FontAwesomeIcons.book,
// //                               color: Colors.white,
// //                               size: 40,
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                     Positioned(
// //                       top: 8,
// //                       right: 8,
// //                       child: Container(
// //                         padding: const EdgeInsets.all(6),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withOpacity(0.9),
// //                           shape: BoxShape.circle,
// //                         ),
// //                         child: Icon(
// //                           Icons.favorite_outline,
// //                           size: 16,
// //                           color: Colors.grey[600],
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             Expanded(
// //               flex: 2,
// //               child: Padding(
// //                 padding: const EdgeInsets.all(12),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           product.name ?? 'Unknown Product',
// //                           style: const TextStyle(
// //                             fontSize: 13,
// //                             fontWeight: FontWeight.w600,
// //                             color: Colors.black,
// //                           ),
// //                           maxLines: 2,
// //                           overflow: TextOverflow.ellipsis,
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           '\$${(product.price ?? 0).toStringAsFixed(2)}',
// //                           style: const TextStyle(
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.blue,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Row(
// //                           children: [
// //                             Container(
// //                               width: 6,
// //                               height: 6,
// //                               decoration: BoxDecoration(
// //                                 color: (product.isAvailable ?? 0) > 0 ? Colors.green : Colors.red,
// //                                 shape: BoxShape.circle,
// //                               ),
// //                             ),
// //                             const SizedBox(width: 4),
// //                             Flexible(
// //                               child: Text(
// //                                 (product.isAvailable ?? 0) > 0 ? 'Available' : 'Not Available',
// //                                 style: TextStyle(
// //                                   fontSize: 10,
// //                                   color: (product.isAvailable ?? 0) > 0 ? Colors.green : Colors.red,
// //                                   fontWeight: FontWeight.w500,
// //                                 ),
// //                                 overflow: TextOverflow.ellipsis,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                     if ((product.isAvailable ?? 0) > 0)
// //                       AddToCartButton(
// //                         product: product,
// //                         onCartUpdated: _updateCartCount,
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProductDetailsSheet(ProductModel product) {
// //     return Container(
// //       height: MediaQuery.of(context).size.height * 0.7,
// //       decoration: const BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       child: Column(
// //         children: [
// //           Container(
// //             margin: const EdgeInsets.only(top: 12),
// //             width: 40,
// //             height: 4,
// //             decoration: BoxDecoration(
// //               color: Colors.grey[300],
// //               borderRadius: BorderRadius.circular(2),
// //             ),
// //           ),
// //           Expanded(
// //             child: SingleChildScrollView(
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Container(
// //                     height: 280,
// //                     width: double.infinity,
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(16),
// //                       color: Colors.grey[100],
// //                     ),
// //                     child: ClipRRect(
// //                       borderRadius: BorderRadius.circular(16),
// //                       child: Image.memory(
// //                         base64Decode(product.imgurl),
// //                         fit: BoxFit.cover,
// //                         errorBuilder: (context, error, stackTrace) {
// //                           return Container(
// //                             decoration: BoxDecoration(
// //                               gradient: LinearGradient(
// //                                 begin: Alignment.topLeft,
// //                                 end: Alignment.bottomRight,
// //                                 colors: [
// //                                   Colors.orange.shade300,
// //                                   Colors.orange.shade600,
// //                                 ],
// //                               ),
// //                               borderRadius: BorderRadius.circular(16),
// //                             ),
// //                             child: const Icon(
// //                               Icons.laptop_mac,
// //                               color: Colors.white,
// //                               size: 60,
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Expanded(
// //                         child: Text(
// //                           product.name ?? 'Unknown Product',
// //                           style: const TextStyle(
// //                             fontSize: 24,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.black,
// //                           ),
// //                         ),
// //                       ),
// //                       Text(
// //                         '\$${(product.price ?? 0).toStringAsFixed(2)}',
// //                         style: const TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.blue,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 12),
// //                   Row(
// //                     children: [
// //                       Container(
// //                         width: 10,
// //                         height: 10,
// //                         decoration: BoxDecoration(
// //                           color: ((product.isAvailable ?? 0) > 0) ? Colors.green : Colors.red,
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 8),
// //                       Text(
// //                         ((product.isAvailable ?? 0) > 0)
// //                             ? 'Available (${product.isAvailable} left)'
// //                             : 'Not Available',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           color: ((product.isAvailable ?? 0) > 0) ? Colors.green : Colors.red,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   const Text(
// //                     'Description',
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.black,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Text(
// //                     product.description ?? 'No description available',
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       color: Colors.grey[600],
// //                       height: 1.5,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 30),
// //                   if ((product.isAvailable ?? 0) > 0)
// //                     SizedBox(
// //                       width: double.infinity,
// //                       height: 56,
// //                       child: AddToCartButton(
// //                         product: product,
// //                         onCartUpdated: () {
// //                           _updateCartCount();
// //                           Navigator.pop(context);
// //                         },
// //                       ),
// //                     ),
// //                   const SizedBox(height: 30),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
//
// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:project/Screens/Customer/Home/profile_avatar_widget.dart';
//
// import '../../Models/ProductModel.dart';
// import '../Cart/cart_controller.dart';
// import '../Cart/cart_screen.dart';
// import 'add_to_cart_button.dart';
// import 'home_controller.dart';
//
// class CategoryModel {
//   final String id;
//   final String categoriesname;
//
//   CategoryModel({required this.id, required this.categoriesname});
// }
//
// class Home extends StatefulWidget {
//   const Home({super.key});
//
//   @override
//   State<Home> createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//   int _selectedIndex = 0;
//   int _cartItemsCount = 0;
//
//   final HomeController _controller = HomeController();
//   final CartController _cartController = CartController();
//   final TextEditingController _searchController = TextEditingController();
//
//   late Future<List<ProductModel>> _futureProducts;
//   late Future<List<CategoryModel>> _futureCategories;
//
//   // Original data
//   Map<String, List<ProductModel>> _productsByCategory = {};
//   Map<String, bool> _expandedCategories = {};
//   Map<String, String> _categoryNames = {};
//   List<ProductModel> _allProducts = [];
//   List<CategoryModel> _allCategories = [];
//
//   // Filtered data for search
//   Map<String, List<ProductModel>> _filteredProductsByCategory = {};
//   List<ProductModel> _filteredProducts = [];
//   bool _isSearching = false;
//   String _searchQuery = '';
//
//   bool _isDataInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _futureProducts = _controller.getAllProducts();
//     _futureCategories = _fetchCategories();
//     _initializeData();
//     _updateCartCount();
//
//     // Add search listener
//     _searchController.addListener(_onSearchChanged);
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _onSearchChanged() {
//     setState(() {
//       _searchQuery = _searchController.text.toLowerCase().trim();
//       _isSearching = _searchQuery.isNotEmpty;
//     });
//
//     if (_isSearching) {
//       _performSearch(_searchQuery);
//     } else {
//       _resetToOriginalData();
//     }
//   }
//
//   void _performSearch(String query) {
//     if (!_isDataInitialized) return;
//
//     // Search in products first
//     List<ProductModel> matchingProducts = _allProducts.where((product) {
//       return product.name.toLowerCase().contains(query) ||
//           product.description.toLowerCase().contains(query);
//     }).toList();
//
//     // Search in categories
//     List<CategoryModel> matchingCategories = _allCategories.where((category) {
//       return category.categoriesname.toLowerCase().contains(query);
//     }).toList();
//
//     // Create filtered data structure
//     Map<String, List<ProductModel>> filteredByCategory = {};
//
//     // Add products that match directly
//     if (matchingProducts.isNotEmpty) {
//       // Group matching products by their categories
//       for (ProductModel product in matchingProducts) {
//         String categoryId = product.categoryid ?? 'unknown';
//         if (filteredByCategory[categoryId] == null) {
//           filteredByCategory[categoryId] = [];
//         }
//         filteredByCategory[categoryId]!.add(product);
//       }
//     }
//
//     // Add all products from matching categories
//     for (CategoryModel category in matchingCategories) {
//       List<ProductModel> categoryProducts = _productsByCategory[category.id] ?? [];
//       if (categoryProducts.isNotEmpty) {
//         if (filteredByCategory[category.id] == null) {
//           filteredByCategory[category.id] = [];
//         }
//         // Avoid duplicates
//         for (ProductModel product in categoryProducts) {
//           if (!filteredByCategory[category.id]!.any((p) => p.id == product.id)) {
//             filteredByCategory[category.id]!.add(product);
//           }
//         }
//       }
//     }
//
//     setState(() {
//       _filteredProductsByCategory = filteredByCategory;
//       _filteredProducts = matchingProducts;
//     });
//   }
//
//   void _resetToOriginalData() {
//     setState(() {
//       _filteredProductsByCategory.clear();
//       _filteredProducts.clear();
//     });
//   }
//
//   Future<void> _initializeData() async {
//     try {
//       final products = await _futureProducts;
//       final categories = await _futureCategories;
//
//       _allProducts = products;
//       _allCategories = categories;
//
//       for (var category in categories) {
//         _categoryNames[category.id] = category.categoriesname;
//         _expandedCategories[category.id] = false;
//       }
//
//       _productsByCategory.clear();
//       for (var product in products) {
//         if (product.categoryid != null && product.categoryid!.isNotEmpty) {
//           if (_productsByCategory[product.categoryid] == null) {
//             _productsByCategory[product.categoryid!] = [];
//           }
//           _productsByCategory[product.categoryid]!.add(product);
//
//           if (!_expandedCategories.containsKey(product.categoryid)) {
//             _expandedCategories[product.categoryid!] = false;
//           }
//         }
//       }
//
//       setState(() {
//         _isDataInitialized = true;
//       });
//     } catch (e) {
//       print('Error initializing data: $e');
//       setState(() {
//         _isDataInitialized = true;
//       });
//     }
//   }
//
//   Future<List<CategoryModel>> _fetchCategories() async {
//     try {
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('categories')
//           .get();
//
//       return snapshot.docs.map((doc) => CategoryModel(
//         id: doc.id,
//         categoriesname: doc['categoriesname'] ?? '',
//       )).toList();
//     } catch (e) {
//       print('Error fetching categories: $e');
//       return [];
//     }
//   }
//
//   Future<void> _updateCartCount() async {
//     try {
//       int count = await _cartController.getCartCount();
//       if (mounted) {
//         setState(() {
//           _cartItemsCount = count;
//         });
//       }
//     } catch (e) {
//       print('Error updating cart count: $e');
//     }
//   }
//
//   void _toggleCategoryExpansion(String categoryId) {
//     setState(() {
//       _expandedCategories[categoryId] = !(_expandedCategories[categoryId] ?? false);
//     });
//   }
//
//   void _showProductDetails(ProductModel product) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => _buildProductDetailsSheet(product),
//     );
//   }
//
//   void _clearSearch() {
//     _searchController.clear();
//     FocusScope.of(context).unfocus();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               color: Colors.white,
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Buy your',
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                           Text(
//                             'favorite gadget',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                       ProfileAvatarWidget(
//                         onLoginRequired: () {
//                           // Handle login navigation
//                         },
//                         onLogoutSuccess: () {
//                           _updateCartCount();
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Enhanced Search Bar
//                   Container(
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(25),
//                       border: _isSearching
//                           ? Border.all(color: Colors.blue, width: 2)
//                           : null,
//                     ),
//                     child: TextField(
//                       controller: _searchController,
//                       decoration: InputDecoration(
//                         hintText: 'Search products or categories...',
//                         hintStyle: TextStyle(color: Colors.grey[500]),
//                         prefixIcon: Icon(
//                             Icons.search,
//                             color: _isSearching ? Colors.blue : Colors.grey[500]
//                         ),
//                         suffixIcon: _isSearching
//                             ? IconButton(
//                           icon: Icon(Icons.clear, color: Colors.grey[600]),
//                           onPressed: _clearSearch,
//                         )
//                             : null,
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 15,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // Search Results Info
//                   if (_isSearching) ...[
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             _getSearchResultsText(),
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//
//             Expanded(
//               child: _isDataInitialized
//                   ? _buildContent()
//                   : const Center(child: CircularProgressIndicator()),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//
//           switch (index) {
//             case 0:
//             // Already on Home
//               break;
//             case 1:
//             // Navigate to Top Trends
//               break;
//             case 2:
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const CartScreen()),
//               );
//               break;
//             case 3:
//             // Navigate to Saved
//               break;
//             case 4:
//             // Navigate to Profile
//               break;
//           }
//         },
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.black,
//         unselectedItemColor: Colors.grey,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home, color: Colors.black),
//             label: 'Home',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_bag_outlined),
//             label: 'Top Trends',
//           ),
//           BottomNavigationBarItem(
//             icon: Stack(
//               children: [
//                 const Icon(Icons.shopping_cart_outlined),
//                 if (_cartItemsCount > 0)
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade400,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       constraints: const BoxConstraints(
//                         minWidth: 16,
//                         minHeight: 16,
//                       ),
//                       child: Text(
//                         '$_cartItemsCount',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             activeIcon: Stack(
//               children: [
//                 const Icon(Icons.shopping_cart),
//                 if (_cartItemsCount > 0)
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       constraints: const BoxConstraints(
//                         minWidth: 16,
//                         minHeight: 16,
//                       ),
//                       child: Text(
//                         '$_cartItemsCount',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             label: 'Cart',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.bookmark_outline),
//             activeIcon: Icon(Icons.bookmark),
//             label: 'Saved',
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             activeIcon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _getSearchResultsText() {
//     if (_isSearching) {
//       int totalProducts = _filteredProductsByCategory.values
//           .fold(0, (sum, products) => sum + products.length);
//       int totalCategories = _filteredProductsByCategory.keys.length;
//
//       if (totalProducts == 0) {
//         return 'No results found for "$_searchQuery"';
//       } else {
//         return 'Found $totalProducts products in $totalCategories categories for "$_searchQuery"';
//       }
//     }
//     return '';
//   }
//
//   Widget _buildContent() {
//     if (_isSearching) {
//       return _buildSearchResults();
//     } else {
//       return _buildOriginalContent();
//     }
//   }
//
//   Widget _buildSearchResults() {
//     if (_filteredProductsByCategory.isEmpty) {
//       return _buildNoSearchResults();
//     }
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         children: _buildSearchCategoryWidgets(),
//       ),
//     );
//   }
//
//   Widget _buildOriginalContent() {
//     if (_productsByCategory.isEmpty) {
//       return const Center(child: Text('No products found'));
//     }
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         children: _buildCategoryWidgets(),
//       ),
//     );
//   }
//
//   Widget _buildNoSearchResults() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.search_off,
//             size: 80,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No results found',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Try searching with different keywords',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: _clearSearch,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.black,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text('Clear Search'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buildSearchCategoryWidgets() {
//     List<Widget> categoryWidgets = [];
//
//     _filteredProductsByCategory.forEach((categoryId, products) {
//       if (products.isNotEmpty) {
//         String categoryName = _categoryNames[categoryId] ?? 'Unknown Category';
//         bool isExpanded = _expandedCategories[categoryId] ?? false;
//
//         // Category Header with search highlight
//         categoryWidgets.add(
//           Padding(
//             padding: const EdgeInsets.only(top: 24, bottom: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: RichText(
//                     text: _buildHighlightedText(categoryName, _searchQuery),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () => _toggleCategoryExpansion(categoryId),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     child: Text(
//                       isExpanded ? 'Close All' : 'See all (${products.length})',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: isExpanded ? Colors.red : Colors.blue,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//
//         // Products Grid
//         List<ProductModel> displayProducts = isExpanded
//             ? products
//             : products.take(4).toList(); // Show more in search results
//
//         categoryWidgets.add(
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             padding: const EdgeInsets.only(bottom: 16),
//             itemCount: displayProducts.length,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 16,
//               childAspectRatio: 0.54,
//             ),
//             itemBuilder: (context, index) {
//               return _buildProductCard(displayProducts[index], isSearchResult: true);
//             },
//           ),
//         );
//       }
//     });
//
//     return categoryWidgets;
//   }
//
//   TextSpan _buildHighlightedText(String text, String query) {
//     if (query.isEmpty) {
//       return TextSpan(
//         text: text,
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//         ),
//       );
//     }
//
//     List<TextSpan> spans = [];
//     String lowerText = text.toLowerCase();
//     String lowerQuery = query.toLowerCase();
//
//     int start = 0;
//     int index = lowerText.indexOf(lowerQuery);
//
//     while (index != -1) {
//       // Add text before match
//       if (index > start) {
//         spans.add(TextSpan(
//           text: text.substring(start, index),
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ));
//       }
//
//       // Add highlighted match
//       spans.add(TextSpan(
//         text: text.substring(index, index + query.length),
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.blue,
//           backgroundColor: Colors.yellow,
//         ),
//       ));
//
//       start = index + query.length;
//       index = lowerText.indexOf(lowerQuery, start);
//     }
//
//     // Add remaining text
//     if (start < text.length) {
//       spans.add(TextSpan(
//         text: text.substring(start),
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//         ),
//       ));
//     }
//
//     return TextSpan(children: spans);
//   }
//
//   List<Widget> _buildCategoryWidgets() {
//     List<Widget> categoryWidgets = [];
//     List<String> allCategoryIds = _categoryNames.keys.toList();
//
//     for (int i = 0; i < allCategoryIds.length; i++) {
//       String categoryId = allCategoryIds[i];
//       String categoryName = _categoryNames[categoryId] ?? 'Unknown Category';
//       List<ProductModel> products = _productsByCategory[categoryId] ?? [];
//       bool isExpanded = _expandedCategories[categoryId] ?? false;
//
//       categoryWidgets.add(
//         Padding(
//           padding: const EdgeInsets.only(top: 24, bottom: 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   categoryName,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               if (products.isNotEmpty)
//                 GestureDetector(
//                   onTap: () => _toggleCategoryExpansion(categoryId),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     child: Text(
//                       isExpanded ? 'Close All' : 'See all',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: isExpanded ? Colors.red : Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       );
//
//       if (products.isNotEmpty) {
//         List<ProductModel> displayProducts = isExpanded
//             ? products
//             : products.take(2).toList();
//
//         categoryWidgets.add(
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             padding: const EdgeInsets.only(bottom: 16),
//             itemCount: displayProducts.length,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 16,
//               childAspectRatio: 0.54,
//             ),
//             itemBuilder: (context, index) {
//               return _buildProductCard(displayProducts[index]);
//             },
//           ),
//         );
//       } else {
//         categoryWidgets.add(
//           Padding(
//             padding: const EdgeInsets.only(bottom: 24),
//             child: Container(
//               height: 100,
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.inventory_2_outlined,
//                         color: Colors.grey[400], size: 32),
//                     const SizedBox(height: 8),
//                     Text(
//                       'No products in this category',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       }
//     }
//
//     return categoryWidgets;
//   }
//
//   Widget _buildProductCard(ProductModel product, {bool isSearchResult = false}) {
//     return GestureDetector(
//       onTap: () => _showProductDetails(product),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: isSearchResult
//               ? Border.all(color: Colors.blue.withOpacity(0.3), width: 1)
//               : null,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               flex: 3,
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                   color: Colors.grey[100],
//                 ),
//                 child: Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                       child: Image.memory(
//                         base64Decode(product.imgurl),
//                         width: double.infinity,
//                         height: double.infinity,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             width: double.infinity,
//                             height: double.infinity,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   Colors.orange.shade300,
//                                   Colors.orange.shade600,
//                                 ],
//                               ),
//                               borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                             ),
//                             child: const Icon(
//                               FontAwesomeIcons.book,
//                               color: Colors.white,
//                               size: 40,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.9),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.favorite_outline,
//                           size: 16,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ),
//                     if (isSearchResult)
//                       Positioned(
//                         top: 8,
//                         left: 8,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.blue,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Text(
//                             'Match',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         RichText(
//                           text: isSearchResult
//                               ? _buildHighlightedProductText(product.name ?? 'Unknown Product', _searchQuery)
//                               : TextSpan(
//                             text: product.name ?? 'Unknown Product',
//                             style: const TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black,
//                             ),
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '\$${(product.price ?? 0).toStringAsFixed(2)}',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Container(
//                               width: 6,
//                               height: 6,
//                               decoration: BoxDecoration(
//                                 color: (product.isAvailable ?? 0) > 0 ? Colors.green : Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             Flexible(
//                               child: Text(
//                                 (product.isAvailable ?? 0) > 0 ? 'Available' : 'Not Available',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: (product.isAvailable ?? 0) > 0 ? Colors.green : Colors.red,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     if ((product.isAvailable ?? 0) > 0)
//                       AddToCartButton(
//                         product: product,
//                         onCartUpdated: _updateCartCount,
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   TextSpan _buildHighlightedProductText(String text, String query) {
//     if (query.isEmpty) {
//       return TextSpan(
//         text: text,
//         style: const TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//         ),
//       );
//     }
//
//     List<TextSpan> spans = [];
//     String lowerText = text.toLowerCase();
//     String lowerQuery = query.toLowerCase();
//
//     int start = 0;
//     int index = lowerText.indexOf(lowerQuery);
//
//     while (index != -1) {
//       if (index > start) {
//         spans.add(TextSpan(
//           text: text.substring(start, index),
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ));
//       }
//
//       spans.add(TextSpan(
//         text: text.substring(index, index + query.length),
//         style: const TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: Colors.blue,
//           backgroundColor: Colors.yellow,
//         ),
//       ));
//
//       start = index + query.length;
//       index = lowerText.indexOf(lowerQuery, start);
//     }
//
//     if (start < text.length) {
//       spans.add(TextSpan(
//         text: text.substring(start),
//         style: const TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//         ),
//       ));
//     }
//
//     return TextSpan(children: spans);
//   }
//
//   Widget _buildProductDetailsSheet(ProductModel product) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.7,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     height: 280,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       color: Colors.grey[100],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: Image.memory(
//                         base64Decode(product.imgurl),
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   Colors.orange.shade300,
//                                   Colors.orange.shade600,
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: const Icon(
//                               Icons.laptop_mac,
//                               color: Colors.white,
//                               size: 60,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           product.name ?? 'Unknown Product',
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         '\$${(product.price ?? 0).toStringAsFixed(2)}',
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Container(
//                         width: 10,
//                         height: 10,
//                         decoration: BoxDecoration(
//                           color: ((product.isAvailable ?? 0) > 0) ? Colors.green : Colors.red,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         ((product.isAvailable ?? 0) > 0)
//                             ? 'Available (${product.isAvailable} left)'
//                             : 'Not Available',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: ((product.isAvailable ?? 0) > 0) ? Colors.green : Colors.red,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Description',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     product.description ?? 'No description available',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   if ((product.isAvailable ?? 0) > 0)
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: AddToCartButton(
//                         product: product,
//                         onCartUpdated: () {
//                           _updateCartCount();
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/Screens/Customer/Home/product_details_sheet.dart';
import 'package:project/Screens/Customer/Home/profile_avatar_widget.dart';
import '../../Models/ProductModel.dart';
import '../Cart/cart_controller.dart';
import '../CustomerProfileUpdate/customer_profile_update_screen.dart';
import '../Wishlist/animated_product_card.dart';
import '../Wishlist/wishlist_screen.dart';
import '../Cart/cart_screen.dart';
import 'home_controller.dart';
import 'add_to_cart_button.dart';

class CategoryModel {
  final String id;
  final String categoriesname;

  CategoryModel({required this.id, required this.categoriesname});
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  int _cartItemsCount = 0;

  final HomeController _controller = HomeController();
  final CartController _cartController = CartController();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<ProductModel>> _futureProducts;
  late Future<List<CategoryModel>> _futureCategories;

  // Original data
  Map<String, List<ProductModel>> _productsByCategory = {};
  Map<String, bool> _expandedCategories = {};
  Map<String, String> _categoryNames = {};
  List<ProductModel> _allProducts = [];
  List<CategoryModel> _allCategories = [];

  // Filtered data for search
  Map<String, List<ProductModel>> _filteredProductsByCategory = {};
  List<ProductModel> _filteredProducts = [];
  bool _isSearching = false;
  String _searchQuery = '';

  bool _isDataInitialized = false;

  @override
  void initState() {
    super.initState();
    _futureProducts = _controller.getAllProducts();
    _futureCategories = _fetchCategories();
    _initializeData();
    _updateCartCount();

    // Add search listener
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
      _isSearching = _searchQuery.isNotEmpty;
    });

    if (_isSearching) {
      _performSearch(_searchQuery);
    } else {
      _resetToOriginalData();
    }
  }

  void _performSearch(String query) {
    if (!_isDataInitialized) return;

    // Search in products first
    List<ProductModel> matchingProducts = _allProducts.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
    }).toList();

    // Search in categories
    List<CategoryModel> matchingCategories = _allCategories.where((category) {
      return category.categoriesname.toLowerCase().contains(query);
    }).toList();

    // Create filtered data structure
    Map<String, List<ProductModel>> filteredByCategory = {};

    // Add products that match directly
    if (matchingProducts.isNotEmpty) {
      // Group matching products by their categories
      for (ProductModel product in matchingProducts) {
        String categoryId = product.categoryid ?? 'unknown';
        if (filteredByCategory[categoryId] == null) {
          filteredByCategory[categoryId] = [];
        }
        filteredByCategory[categoryId]!.add(product);
      }
    }

    // Add all products from matching categories
    for (CategoryModel category in matchingCategories) {
      List<ProductModel> categoryProducts = _productsByCategory[category.id] ?? [];
      if (categoryProducts.isNotEmpty) {
        if (filteredByCategory[category.id] == null) {
          filteredByCategory[category.id] = [];
        }
        // Avoid duplicates
        for (ProductModel product in categoryProducts) {
          if (!filteredByCategory[category.id]!.any((p) => p.id == product.id)) {
            filteredByCategory[category.id]!.add(product);
          }
        }
      }
    }

    setState(() {
      _filteredProductsByCategory = filteredByCategory;
      _filteredProducts = matchingProducts;
    });
  }

  void _resetToOriginalData() {
    setState(() {
      _filteredProductsByCategory.clear();
      _filteredProducts.clear();
    });
  }

  Future<void> _initializeData() async {
    try {
      final products = await _futureProducts;
      final categories = await _futureCategories;

      _allProducts = products;
      _allCategories = categories;

      for (var category in categories) {
        _categoryNames[category.id] = category.categoriesname;
        _expandedCategories[category.id] = false;
      }

      _productsByCategory.clear();
      for (var product in products) {
        if (product.categoryid != null && product.categoryid!.isNotEmpty) {
          if (_productsByCategory[product.categoryid] == null) {
            _productsByCategory[product.categoryid!] = [];
          }
          _productsByCategory[product.categoryid]!.add(product);

          if (!_expandedCategories.containsKey(product.categoryid)) {
            _expandedCategories[product.categoryid!] = false;
          }
        }
      }

      setState(() {
        _isDataInitialized = true;
      });
    } catch (e) {
      print('Error initializing data: $e');
      setState(() {
        _isDataInitialized = true;
      });
    }
  }

  Future<List<CategoryModel>> _fetchCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();

      return snapshot.docs.map((doc) => CategoryModel(
        id: doc.id,
        categoriesname: doc['categoriesname'] ?? '',
      )).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
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

  void _toggleCategoryExpansion(String categoryId) {
    setState(() {
      _expandedCategories[categoryId] = !(_expandedCategories[categoryId] ?? false);
    });
  }

  // void _showProductDetails(ProductModel product) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => _buildProductDetailsSheet(product),
  //   );
  // }


  void _showProductDetails(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailsSheet(
        product: product,
        onCartUpdated: _updateCartCount,
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                            'Buy your',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'favorite gadget',
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
                          _updateCartCount();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Enhanced Search Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: _isSearching
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products or categories...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(
                            Icons.search,
                            color: _isSearching ? Colors.blue : Colors.grey[500]
                        ),
                        suffixIcon: _isSearching
                            ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: _clearSearch,
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  // Search Results Info
                  if (_isSearching) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getSearchResultsText(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            Expanded(
              child: _isDataInitialized
                  ? _buildContent()
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
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

  String _getSearchResultsText() {
    if (_isSearching) {
      int totalProducts = _filteredProductsByCategory.values
          .fold(0, (sum, products) => sum + products.length);
      int totalCategories = _filteredProductsByCategory.keys.length;

      if (totalProducts == 0) {
        return 'No results found for "$_searchQuery"';
      } else {
        return 'Found $totalProducts products in $totalCategories categories for "$_searchQuery"';
      }
    }
    return '';
  }

  Widget _buildContent() {
    if (_isSearching) {
      return _buildSearchResults();
    } else {
      return _buildOriginalContent();
    }
  }

  Widget _buildSearchResults() {
    if (_filteredProductsByCategory.isEmpty) {
      return _buildNoSearchResults();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _buildSearchCategoryWidgets(),
      ),
    );
  }

  Widget _buildOriginalContent() {
    if (_productsByCategory.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _buildCategoryWidgets(),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSearchCategoryWidgets() {
    List<Widget> categoryWidgets = [];

    _filteredProductsByCategory.forEach((categoryId, products) {
      if (products.isNotEmpty) {
        String categoryName = _categoryNames[categoryId] ?? 'Unknown Category';
        bool isExpanded = _expandedCategories[categoryId] ?? false;

        // Category Header with search highlight
        categoryWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: _buildHighlightedText(categoryName, _searchQuery),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleCategoryExpansion(categoryId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      isExpanded ? 'Close All' : 'See all (${products.length})',
                      style: TextStyle(
                        fontSize: 14,
                        color: isExpanded ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        // Products Grid
        List<ProductModel> displayProducts = isExpanded
            ? products
            : products.take(4).toList(); // Show more in search results

        categoryWidgets.add(
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: displayProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.54,
            ),
            itemBuilder: (context, index) {
              return AnimatedProductCard(
                product: displayProducts[index],
                onTap: () => _showProductDetails(displayProducts[index]),
                onCartUpdated: _updateCartCount,
                isSearchResult: true,
              );
            },
          ),
        );
      }
    });

    return categoryWidgets;
  }

  TextSpan _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          backgroundColor: Colors.yellow,
        ),
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ));
    }

    return TextSpan(children: spans);
  }

  List<Widget> _buildCategoryWidgets() {
    List<Widget> categoryWidgets = [];
    List<String> allCategoryIds = _categoryNames.keys.toList();

    for (int i = 0; i < allCategoryIds.length; i++) {
      String categoryId = allCategoryIds[i];
      String categoryName = _categoryNames[categoryId] ?? 'Unknown Category';
      List<ProductModel> products = _productsByCategory[categoryId] ?? [];
      bool isExpanded = _expandedCategories[categoryId] ?? false;

      categoryWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (products.isNotEmpty)
                GestureDetector(
                  onTap: () => _toggleCategoryExpansion(categoryId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      isExpanded ? 'Close All' : 'See all',
                      style: TextStyle(
                        fontSize: 14,
                        color: isExpanded ? Colors.red : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

      if (products.isNotEmpty) {
        List<ProductModel> displayProducts = isExpanded
            ? products
            : products.take(2).toList();

        categoryWidgets.add(
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: displayProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.54,
            ),
            itemBuilder: (context, index) {
              return AnimatedProductCard(
                product: displayProducts[index],
                onTap: () => _showProductDetails(displayProducts[index]),
                onCartUpdated: _updateCartCount,
              );
            },
          ),
        );
      } else {
        categoryWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        color: Colors.grey[400], size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'No products in this category',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return categoryWidgets;
  }

  Widget _buildProductDetailsSheet(ProductModel product) {
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
                        base64Decode(product.imgurl),
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name ?? 'Unknown Product',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        '\$${(product.price ?? 0).toStringAsFixed(2)}',
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
                          color: ((product.isAvailable ?? 0) > 0) ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ((product.isAvailable ?? 0) > 0)
                            ? 'Available (${product.isAvailable} left)'
                            : 'Not Available',
                        style: TextStyle(
                          fontSize: 16,
                          color: ((product.isAvailable ?? 0) > 0) ? Colors.green : Colors.red,
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
                    product.description ?? 'No description available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if ((product.isAvailable ?? 0) > 0)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: AddToCartButton(
                        product: product,
                        onCartUpdated: () {
                          _updateCartCount();
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