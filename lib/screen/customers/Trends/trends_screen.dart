import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/customers/Trends/trending_product_card.dart';
import 'package:project/screen/model/ProductModel.dart';

import '../base_customer_screen.dart';

class TrendsScreen extends StatefulWidget {
  @override
  _TrendsScreenState createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen>
    with TickerProviderStateMixin {
  List<ProductModel> _trendingProducts = [];
  List<ProductModel> _newArrivals = [];
  bool _isLoading = true;

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadTrendingData();
  }

  Future<void> _loadTrendingData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load trending products - filter by description containing "trending" or "Trending"
      QuerySnapshot trendingSnapshot = await FirebaseFirestore.instance
          .collection('Books')
          .get();

      List<ProductModel> allProducts = ProductModel.fromQuerySnapshot(trendingSnapshot);

      // Filter trending products by description
      List<ProductModel> trendingFiltered = allProducts.where((product) {
        return product.description.toLowerCase().contains('trending');
      }).toList();

      // Load new arrivals - products added in current month
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      QuerySnapshot newArrivalsSnapshot = await FirebaseFirestore.instance
          .collection('Books')
          .where('CreatedAt', isGreaterThanOrEqualTo: startOfMonth)
          .where('CreatedAt', isLessThanOrEqualTo: endOfMonth)
          .get();

      List<ProductModel> newArrivalsFiltered = ProductModel.fromQuerySnapshot(newArrivalsSnapshot);

      setState(() {
        _trendingProducts = trendingFiltered;
        _newArrivals = newArrivalsFiltered;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      print('Error loading trending data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTrendingTab(),
                  _buildNewArrivalsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EnhancedBottomNavigation(currentIndex: 1,),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[400]!, Colors.red[400]!],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Trending Now',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search
          },
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            // TODO: Implement filters
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.orange[400],
        labelColor: Colors.orange[400],
        unselectedLabelColor: Colors.grey[600],
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          Tab(text: 'Trending'),
          Tab(text: 'New Arrivals'),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[400]!),
          ),
          SizedBox(height: 16),
          Text(
            'Loading trending products...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTab() {
    return _buildProductGrid(_trendingProducts, 'trending');
  }

  Widget _buildNewArrivalsTab() {
    return _buildProductGrid(_newArrivals, 'new');
  }

  Widget _buildProductGrid(List<ProductModel> products, String type) {
    if (products.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _loadTrendingData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Enhanced responsive grid calculation
          int crossAxisCount;
          double childAspectRatio;
          double horizontalPadding;

          if (constraints.maxWidth < 600) {
            // Mobile: 2 columns
            crossAxisCount = 2;
            childAspectRatio = 0.68; // Adjusted for better fit
            horizontalPadding = 12;
          } else if (constraints.maxWidth < 900) {
            // Tablet: 3 columns
            crossAxisCount = 3;
            childAspectRatio = 0.72;
            horizontalPadding = 16;
          } else {
            // Desktop: 4 columns
            crossAxisCount = 4;
            childAspectRatio = 0.75;
            horizontalPadding = 20;
          }

          return GridView.builder(
            padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                100 // Extra bottom padding to prevent overflow
            ),
            physics: AlwaysScrollableScrollPhysics(), // Ensure scrollability
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return TrendingProductCard(
                product: products[index],
                index: index,
                type: type,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    IconData icon;
    String title;
    String subtitle;

    switch (type) {
      case 'new':
        icon = Icons.new_releases;
        title = 'No New Arrivals';
        subtitle = 'Check back soon for new products';
        break;
      default:
        icon = Icons.local_fire_department;
        title = 'No Trending Products';
        subtitle = 'Hot products will appear here';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: Colors.orange[300],
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}