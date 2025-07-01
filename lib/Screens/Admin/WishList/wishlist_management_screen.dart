import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/Screens/Admin/WishList/wishlist_details_sheet.dart';
import '../AdminDrawer.dart';
import 'admin_wishlist_controller.dart';

class WishlistManagementScreen extends StatefulWidget {
  final int selectedIndex;

  const WishlistManagementScreen({
    Key? key,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  State<WishlistManagementScreen> createState() => _WishlistManagementScreenState();
}

class _WishlistManagementScreenState extends State<WishlistManagementScreen>
    with TickerProviderStateMixin {
  final AdminWishlistController _controller = AdminWishlistController();
  final TextEditingController _searchController = TextEditingController();
  
  List<AdminWishlistItem> _wishlistItems = [];
  List<AdminWishlistItem> _filteredItems = [];
  WishlistStats? _stats;
  bool _isLoading = true;
  String _searchQuery = '';
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadWishlistData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWishlistData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _controller.getAllWishlistItems();
      final stats = await _controller.getWishlistStats();
      
      setState(() {
        _wishlistItems = items;
        _filteredItems = items;
        _stats = stats;
        _isLoading = false;
      });
      
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading wishlist data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredItems = _wishlistItems;
      } else {
        _filteredItems = _wishlistItems.where((item) {
          final productName = item.product.name?.toLowerCase() ?? '';
          final userName = item.user.userName?.toLowerCase() ?? '';
          final userEmail = item.user.email?.toLowerCase() ?? '';
          final notes = item.wishlistItem.notes?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          
          return productName.contains(searchLower) ||
                 userName.contains(searchLower) ||
                 userEmail.contains(searchLower) ||
                 notes.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        title: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 100),
            child: Row(
              children: [
                Text("Wishlist Management")
              ],
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: AdminDrawer(
        isDarkMode: false,
        selectedNavIndex: widget.selectedIndex,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildStatsHeader(),
                    _buildSearchBar(),
                    Expanded(child: _buildWishlistGrid()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue[600]!.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue[600]!.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Wishlist Data...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.blue[100],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildStatsHeader() {
  //   if (_stats == null) return const SizedBox.shrink();
  //
  //
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       final screenWidth = MediaQuery.of(context).size.width;
  //       final isSmallScreen = screenWidth < 400;
  //
  //       return Container(
  //         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //             colors: [
  //               Colors.indigo.shade500,
  //               Colors.blue.shade700,
  //             ],
  //           ),
  //           borderRadius: BorderRadius.circular(18),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.blue.shade400.withOpacity(0.25),
  //               blurRadius: 16,
  //               offset: const Offset(0, 6),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
  //                 const SizedBox(width: 10),
  //                 Text(
  //                   'Wishlist Analytics',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: isSmallScreen ? 16 : 18,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // Row 1
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: _buildStatCard(
  //                     'Total Items',
  //                     _stats!.totalItems.toString(),
  //                     Icons.favorite,
  //                     Colors.white,
  //                     //fontSize: isSmallScreen ? 14 : 16,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 Expanded(
  //                   child: _buildStatCard(
  //                     'Unique Users',
  //                     _stats!.uniqueUsers.toString(),
  //                     Icons.people,
  //                     Colors.white,
  //                    // fontSize: isSmallScreen ? 14 : 16,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 10),
  //
  //             // Row 2
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: _buildStatCard(
  //                     'With Notes',
  //                     _stats!.itemsWithNotes.toString(),
  //                     Icons.note,
  //                     Colors.white,
  //                     //fontSize: isSmallScreen ? 14 : 16,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 Expanded(
  //                   child: _buildStatCard(
  //                     'Top Product',
  //                     _stats!.mostWishlistedCount.toString(),
  //                     Icons.trending_up,
  //                     Colors.white,
  //                    // fontSize: isSmallScreen ? 14 : 16,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  //
  // }
  //
  //
  // Widget _buildStatCard(String title, String value, IconData icon, Color color) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.15),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.white.withOpacity(0.2)),
  //     ),
  //     child: Column(
  //       children: [
  //         Icon(icon, color: color, size: 24),
  //         const SizedBox(height: 8),
  //         Text(
  //           value,
  //           style: TextStyle(
  //             color: color,
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         Text(
  //           title,
  //           style: TextStyle(
  //             color: color,
  //             fontSize: 12,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //

  Widget _buildStatsHeader() {
    if (_stats == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Wishlist Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Last 30 days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  title: 'Total Items',
                  value: _stats!.totalItems.toString(),
                  icon: Icons.favorite_outline,
                  color: Colors.blue.shade400,
                  backgroundColor: Colors.blue.shade50,
                  changePercent: '+12.5%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactStatCard(
                  title: 'Active Users',
                  value: _stats!.uniqueUsers.toString(),
                  icon: Icons.people_outline,
                  color: Colors.purple.shade400,
                  backgroundColor: Colors.purple.shade50,
                  changePercent: '+8.2%',
                  isPositive: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  title: 'With Notes',
                  value: _stats!.itemsWithNotes.toString(),
                  icon: Icons.note_outlined,
                  color: Colors.green.shade400,
                  backgroundColor: Colors.green.shade50,
                  changePercent: '+5.1%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactStatCard(
                  title: 'Top Product',
                  value: _stats!.mostWishlistedCount.toString(),
                  icon: Icons.trending_up_outlined,
                  color: Colors.orange.shade400,
                  backgroundColor: Colors.orange.shade50,
                  changePercent: '+15.3%',
                  isPositive: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Popular Products Section
          _buildPopularProductsSection(),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String changePercent,
    required bool isPositive,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animationValue),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            size: 12,
                            color: isPositive
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            changePercent,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isPositive
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 600),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  child: TweenAnimationBuilder<int>(
                    duration: const Duration(milliseconds: 1000),
                    tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
                    builder: (context, animatedValue, child) {
                      return Text(animatedValue.toString());
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularProductsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Most Wishlisted Products',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to full wishlist management
                },
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(3, (index) {
                return Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  child: _buildMiniProductCard(index),
                );
              }),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Added ${_stats!.totalItems} items to wishlist this month',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniProductCard(int index) {
    final colors = [
      Colors.blue.shade100,
      Colors.purple.shade100,
      Colors.green.shade100,
    ];

    final icons = [
      Icons.book_outlined,
      Icons.laptop_mac_outlined,
      Icons.phone_android_outlined,
    ];

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors[index % colors.length],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icons[index % icons.length],
              color: Colors.grey.shade700,
              size: 20,
            ),
          ),
        );
      },
    );
  }



  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterItems,
        decoration: InputDecoration(
          hintText: 'Search by product, user, or notes...',
          prefixIcon: Icon(Icons.search, color: Colors.blue[600]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                    _filterItems('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildWishlistGrid() {
    if (_filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return _buildWishlistCard(_filteredItems[index], index);
      },
    );
  }

  Widget _buildWishlistCard(AdminWishlistItem item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () => _showWishlistDetails(item),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
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
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue[400]!,
                            Colors.blue[600]!,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.memory(
                              base64Decode(item.product.imgurl),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Heart Icon
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          
                          // Notes Indicator
                          if (item.wishlistItem.notes != null && item.wishlistItem.notes!.isNotEmpty)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.note,
                                  color: Colors.white,
                                  size: 14,
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
                        children: [
                          Text(
                            item.product.name ?? 'Unknown Product',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${(item.product.price ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  (item.user.userName?.isNotEmpty == true)
                                      ? item.user.userName![0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.user.userName ?? 'Unknown User',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_outline,
              size: 60,
              color: Colors.blue[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty ? 'No Wishlist Items Found' : 'No Results Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? 'Users haven\'t added any items to their wishlist yet.'
                : 'Try adjusting your search terms.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showWishlistDetails(AdminWishlistItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WishlistDetailsSheet(
        item: item,
        onDelete: () {
          _deleteWishlistItem(item);
        },
      ),
    );
  }

  Future<void> _deleteWishlistItem(AdminWishlistItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wishlist Item'),
        content: Text(
          'Are you sure you want to remove "${item.product.name}" from ${item.user.userName}\'s wishlist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _controller.deleteWishlistItem(
        item.wishlistItem.userId,
        item.wishlistItem.productId,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Wishlist item deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadWishlistData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to delete wishlist item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}