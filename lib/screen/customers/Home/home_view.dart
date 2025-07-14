import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/screen/customers/Home/product_details_sheet.dart';
import 'package:project/screen/customers/Home/profile_avatar_widget.dart';
import 'package:project/screen/customers/base_customer_screen.dart';
import 'package:project/screen/model/ProductModel.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../Admin/UpdateProduct/update_product_view.dart';
import '../Cart/cart_controller.dart';
import '../CustomerProfileUpdate/customer_profile_update_screen.dart';
import '../Wishlist/animated_product_card.dart';
import '../Wishlist/wishlist_screen.dart';
import '../Cart/cart_screen.dart';
import '../animated_app_bar.dart';
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










  // Add these variables to your _HomeState class
  bool _isAdmin = false;
  String? _currentUserEmail;

// Add this method to your _HomeState class
  Future<void> _checkUserRole() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');

      if (email != null && email.isNotEmpty) {
        setState(() {
          _currentUserEmail = email;
        });

        // Check user role in Firestore
        QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('User')
            .where('Email', isEqualTo: email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          String userRole = userQuery.docs.first['Role'] ?? 'Customer';
          setState(() {
            _isAdmin = userRole.toLowerCase() == 'admin';
          });
        }
      }
    } catch (e) {
      print('Error checking user role: $e');
      setState(() {
        _isAdmin = false;
      });
    }
  }

// Call this method in your initState()
  @override
  void initState() {
    super.initState();
    _futureProducts = _controller.getAllProducts();
    _futureCategories = _fetchCategories();
    _initializeData();
    _updateCartCount();
    _checkUserRole(); // Add this line
    ReversecheckoutCartItems(context);
    _searchController.addListener(_onSearchChanged);




  }

// Update your AnimatedProductCard to include the update icon
// In your existing AnimatedProductCard widget, modify it to accept an isAdmin parameter
// and show the update icon when admin is true

// Add this method to handle update navigation
  void _navigateToUpdateProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProductPage(
          product: product,
          selectedIndex: 1, // Adjust based on your navigation
        ),
      ),
    ).then((_) {
      // Refresh the product list after update
      setState(() {
        _futureProducts = _controller.getAllProducts();
        _initializeData();
      });
    });
  }







  Future<void> ReversecheckoutCartItems(BuildContext context) async {
    try {

      print("hi how are you?");
      // Get current user email from preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');
      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recommended! To Login')),
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
print("hi user id $userId");



      // delete checkout items a/c to userid and orderplaced is false
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Checkout')
          .where('userId', isEqualTo: userId)
          .where('orderStatus', isEqualTo: "Pending")
          .get();

      for (DocumentSnapshot doc in snapshot.docs) {
     print("this is that document id${doc.id}");
      }

      if(snapshot!=null) {
        for (DocumentSnapshot doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
      // Update all cart items for this user to isCheckedOut: true
      QuerySnapshot cartQuery = await FirebaseFirestore.instance
          .collection('Cart')
          .where('UserId', isEqualTo: userId)
          .where('isCheckedOut', isEqualTo: true)
          .where('OrderPlaced', isEqualTo: false)
          .get();
      if(cartQuery!=null) {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (QueryDocumentSnapshot doc in cartQuery.docs) {
          batch.update(doc.reference, {'isCheckedOut': false});
        }
        await batch.commit();
      }


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
      builder: (context) => EnhancedProductDetailsSheet(
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
        appBar: AnimatedAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
      // bottomNavigationBar:EnhancedBottomNavigation(5) ,

      bottomNavigationBar: EnhancedBottomNavigation(currentIndex: 0,));
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
                isSearchResult: true, // or false for regular categories
                isAdmin: _isAdmin, // Add this
                onUpdateTap: () => _navigateToUpdateProduct(displayProducts[index]), // Add this
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
                isSearchResult: true, // or false for regular categories
                isAdmin: _isAdmin, // Add this
                onUpdateTap: () => _navigateToUpdateProduct(displayProducts[index]), // Add this
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
                          color: ((product.quantity ?? 0) > 0) ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ((product.quantity ?? 0) > 0)
                            ? 'Available (${product.quantity} left)'
                            : 'Not Available',
                        style: TextStyle(
                          fontSize: 16,
                          color: ((product.quantity ?? 0) > 0) ? Colors.green : Colors.red,
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
                  if ((product.quantity ?? 0) > 0)
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