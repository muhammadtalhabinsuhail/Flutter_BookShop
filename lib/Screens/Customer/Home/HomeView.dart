import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/Screens/Customer/CustomerProfileUpdate/customer_profile_update_screen.dart';
import '../../Admin/AdminDashboard/AdminDashboardView.dart';
import '../../Models/ProductModel.dart';
import '../Cart/CartScreen.dart';
import 'HomeController.dart';

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
  int _selectedIndex = 0; // Shop tab is selected
  int _cartItemsCount = 3; // Will be made dynamic later

  final Homecontroller _controller = Homecontroller();
  late Future<List<ProductModel>> _futureProducts;
  late Future<List<CategoryModel>> _futureCategories;

  Map<String, List<ProductModel>> _productsByCategory = {};
  Map<String, bool> _expandedCategories = {};
  Map<String, String> _categoryNames = {};
  bool _isDataInitialized = false;

  @override
  void initState() {
    super.initState();
    _futureProducts = _controller.getAllProducts();
    _futureCategories = _fetchCategories();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final products = await _futureProducts;
      final categories = await _futureCategories;

      // Create category name mapping
      for (var category in categories) {
        _categoryNames[category.id] = category.categoriesname;
        _expandedCategories[category.id] = false; // Initialize as false
      }

      // Group products by category
      _productsByCategory.clear();
      for (var product in products) {
        if (product.categoryid != null && product.categoryid!.isNotEmpty) {
          if (_productsByCategory[product.categoryid] == null) {
            _productsByCategory[product.categoryid!] = [];
          }
          _productsByCategory[product.categoryid]!.add(product);

          // Ensure category expansion state is initialized
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
        _isDataInitialized = true; // Set to true even on error to show error state
      });
    }
  }

  // Add this method to your HomeController class
  Future<List<CategoryModel>> _fetchCategories() async {
    // Replace this with your actual Firebase fetch logic
    try {
      // Example implementation - replace with your actual Firebase code

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();

      return snapshot.docs.map((doc) => CategoryModel(
        id: doc.id,
        categoriesname: doc['categoriesname'] ?? '',
      )).toList();


      // Temporary mock data - replace with actual implementation
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return [
        CategoryModel(id: 'cat1', categoriesname: 'Electronics'),
        CategoryModel(id: 'cat2', categoriesname: 'Books'),
        CategoryModel(id: 'cat3', categoriesname: 'Clothing'),
      ];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  void _updateCartCount() async {
    try {
      final productList = await _futureProducts;
      int totalItems = 0;

      for (var product in productList) {
        totalItems += product.quantity ?? 0; // Add null safety
      }

      if (mounted) {
        setState(() {
          _cartItemsCount = totalItems;
        });
      }
    } catch (e) {
      print('Error updating cart count: $e');
    }
  }

  void _incrementQuantity(ProductModel product) {
    if (product.quantity > 0) {
      setState(() {
        product.quantity = (product.quantity ?? 0) + 1; // Add null safety
      });
      _updateCartCount();
    }
  }

  void _decrementQuantity(ProductModel product) {
    int currentQuantity = product.quantity ?? 0;
    if (currentQuantity > 0) {
      setState(() {
        product.quantity = currentQuantity - 1;
      });
      _updateCartCount();
    }
  }

  void _toggleCategoryExpansion(String categoryId) {
    setState(() {
      // Use null-aware operator and provide default value
      _expandedCategories[categoryId] = !(_expandedCategories[categoryId] ?? false);
    });
  }

  void _showProductDetails(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProductDetailsSheet(product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // STICKY HEADER SECTION
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
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
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search gadgets',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SCROLLABLE CONTENT WITH DYNAMIC CATEGORIES
            Expanded(
              child: _isDataInitialized
                  ? (_productsByCategory.isEmpty
                  ? const Center(child: Text('No products found'))
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: _buildCategoryWidgets(),
                ),
              )
              )
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

          // Navigation logic
          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
              break;
            case 1:
            //Navigator.push(context, MaterialPageRoute(builder: (context) => TopTrendsScreen()));
              break;
            case 2:
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen()));
              break;
            case 3:
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboard(selectedIndex: 0,)));
              break;
            case 4:
              Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerProfileUpdateScreen()));
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
            activeIcon: Icon(Icons.home,color: Colors.black,),
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
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
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




  //
  // List<Widget> _buildCategoryWidgets() {
  //   List<Widget> categoryWidgets = [];
  //
  //   _productsByCategory.forEach((categoryId, products) {
  //     if (products.isNotEmpty) {
  //       int index = 0;
  //       String categoryName = _categoryNames[categoryId] ?? 'Unknown Category';
  //       bool isExpanded = _expandedCategories[categoryId] ?? false; // Add null safety
  //
  //       // Category Header
  //       categoryWidgets.add(
  //         Padding(
  //           padding: const EdgeInsets.only(top: 24, bottom: 16),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 categoryName,
  //                 style: const TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               GestureDetector(
  //                 onTap: () => _toggleCategoryExpansion(categoryId),
  //                 child: Text(
  //                   isExpanded ? 'Close All' : 'See all',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     color: isExpanded ? Colors.red : Colors.grey[600],
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //
  //       // Products Grid
  //       List<ProductModel> displayProducts = (isExpanded) ? products : products.take(2).toList();
  //
  //       categoryWidgets.add(
  //         GridView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           padding: const EdgeInsets.only(bottom: 16),
  //           itemCount: displayProducts.length,
  //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //             crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
  //             crossAxisSpacing: 12,
  //             mainAxisSpacing: 16,
  //             childAspectRatio: 0.54,
  //           ),
  //           itemBuilder: (context, index) {
  //             return _buildProductCard(displayProducts[index]);
  //           },
  //         ),
  //       );
  //     }
  //   });
  //
  //   return categoryWidgets;
  // }

  List<Widget> _buildCategoryWidgets() {
    List<Widget> categoryWidgets = [];

    print('=== DEBUG INFO ===');
    print('_productsByCategory keys: ${_productsByCategory.keys.toList()}');
    print('_categoryNames: $_categoryNames');
    print('All category IDs: ${_categoryNames.keys.toList()}');

    // Iterate through ALL categories, not just ones with products
    List<String> allCategoryIds = _categoryNames.keys.toList();

    for (int i = 0; i < allCategoryIds.length; i++) {
      String categoryId = allCategoryIds[i];
      String categoryName = _categoryNames[categoryId] ?? 'Unknown Category';
      List<ProductModel> products = _productsByCategory[categoryId] ?? []; // Empty list if no products
      bool isExpanded = _expandedCategories[categoryId] ?? false;

      print('Processing category $i: ID=$categoryId, Name=$categoryName, Products count=${products.length}');

      // Show category header even if no products
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
              if (products.isNotEmpty) // Only show "See all" if there are products
                GestureDetector(
                  onTap: () {
                    print('Tapping category: $categoryId ($categoryName)');
                    _toggleCategoryExpansion(categoryId);
                  },
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
        // Products Grid
        List<ProductModel> displayProducts = isExpanded
            ? products
            : products.take(2).toList();

        print('Displaying ${displayProducts.length} products for category: $categoryName');

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
              return _buildProductCard(displayProducts[index]);
            },
          ),
        );
      } else {
        // Show "No products" message for empty categories
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

    print('Total category widgets created: ${categoryWidgets.length}');
    return categoryWidgets;
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Product Image
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
                        base64Decode(product.imgurl),
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
                    // Favorite Icon
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Details
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
                        // Product Name
                        Text(
                          product.name ?? 'Unknown Product', // Add null safety
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Product Price
                        Text(
                          '\$${(product.price ?? 0).toStringAsFixed(2)}', // Add null safety
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Availability Status
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: (product.isAvailable ?? 0) > 0 ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                (product.isAvailable ?? 0) > 0 ? 'Available' : 'Not Available',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: (product.isAvailable ?? 0) > 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Quantity Controls - Only show if available
                    if ((product.isAvailable ?? 0) > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _decrementQuantity(product),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: (product.quantity ?? 0) > 0 ? Colors.red : Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 12,
                                color: (product.quantity ?? 0) > 0 ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            child: Text(
                              '${product.quantity ?? 0}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _incrementQuantity(product),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailsSheet(ProductModel product) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // Increased height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
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
                  // Product Image - Increased height
                  Container(
                    height: 280, // Increased from 200 to 280
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

                  // Product Title and Price
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

                  // Availability Status
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

                  // Description
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

                  // Add to Cart Button
                  if ((product.isAvailable ?? 0) > 0)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          _incrementQuantity(product);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name ?? 'Product'} added to cart!'),
                              backgroundColor: Colors.black,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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


