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
  List<ProductModel> _bestSellers = [];
  bool _isLoading = true;
  
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      // Load trending products (you can implement your own logic)
      QuerySnapshot productsSnapshot = await FirebaseFirestore.instance
          .collection('Books')
          .limit(20)
          .get();

      List<ProductModel> allProducts = ProductModel.fromQuerySnapshot(productsSnapshot);
      
      setState(() {
        _trendingProducts = allProducts.take(8).toList();
        _newArrivals = allProducts.skip(8).take(6).toList();
        _bestSellers = allProducts.take(6).toList();
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
                        _buildBestSellersTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        bottomNavigationBar: EnhancedBottomNavigation(currentIndex: 1,)
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
          Tab(text: 'Best Sellers'),
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

  Widget _buildBestSellersTab() {
    return _buildProductGrid(_bestSellers, 'bestseller');
  }

  Widget _buildProductGrid(List<ProductModel> products, String type) {
    if (products.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _loadTrendingData,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
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
      case 'bestseller':
        icon = Icons.star;
        title = 'No Best Sellers';
        subtitle = 'Popular products will appear here';
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