import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project/screen/Admin/WishList/admin_wishlist_controller.dart';

import '../AdminDrawer.dart';

class AdminDashboard extends StatefulWidget {
  final int selectedIndex;
  const AdminDashboard({super.key, required this.selectedIndex});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isDarkMode = false;
  int _selectedNavIndex = 0;

  // Wishlist Controller
  final AdminWishlistController _wishlistController = AdminWishlistController();
  WishlistStats? _wishlistStats;
  bool _isLoadingWishlist = true;

  final List<NavItem> _navItems = [
    NavItem(Icons.home_outlined, Icons.home, 'Home'),
    NavItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Products'),
    NavItem(Icons.people_outline, Icons.people, 'Customers'),
    NavItem(Icons.store_outlined, Icons.store, 'Shop'),
    NavItem(Icons.trending_up_outlined, Icons.trending_up, 'Income'),
    NavItem(Icons.campaign_outlined, Icons.campaign, 'Promote'),
  ];

  final List<Product> _popularProducts = [
    Product('Crypter - NFT UI kit', '\$2,453.80', 'Active', Colors.orange),
    Product('Bento Matte 3D illustration 1.0', '\$105.60', 'Inactive', Colors.pink),
    Product('Excellent material 3D chair', '\$648.60', 'Active', Colors.blue),
    Product('Fleet - travel shopping kit', '\$648.60', 'Active', Colors.purple),
  ];

  @override
  void initState() {
    super.initState();
    _loadWishlistData();
  }

  Future<void> _loadWishlistData() async {
    try {
      final stats = await _wishlistController.getWishlistStats();
      setState(() {
        _wishlistStats = stats;
        _isLoadingWishlist = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWishlist = false;
      });
      print('Error loading wishlist data: $e');
    }
  }

  ThemeData get _lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    primaryColor: Colors.blue,
  );

  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.black,
    primaryColor: Colors.blue,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? _darkTheme : _lightTheme,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          title: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 100),
              child: Row(
                children: [
                  Text("Product Management")
                ],
              ),
            ),
          ),
          centerTitle: true,
        ),
        drawer: AdminDrawer(
          isDarkMode: _isDarkMode,
          selectedNavIndex: widget.selectedIndex,
        ),
        body: Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const SizedBox(width: 16),
              //Search Box
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search product',
                    prefixIcon: Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              //Bell Icon
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
              ),
              const SizedBox(width: 8),
              //Profile Picture
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Dashboard Title
          const Text(
            'Admin Controls',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Section
                  _buildOverviewSection(),
                  const SizedBox(height: 24),

                  // Wishlist Analytics Section
                  _buildWishlistAnalyticsSection(),
                  const SizedBox(height: 24),

                  // Charts Section
                  _buildWishlistSection(),
                  const SizedBox(height: 24),

                  _buildPopularProductsCard(),
                  const SizedBox(height: 24),

                  // Get More Customers Section
                  _buildGetMoreCustomersSection(),
                  const SizedBox(height: 16),

                  buildAllCommentsCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistAnalyticsSection() {
    if (_isLoadingWishlist) {
      return Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
          ),
        ),
      );
    }

    if (_wishlistStats == null) return const SizedBox.shrink();

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    value: _wishlistStats!.totalItems.toString(),
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
                    value: _wishlistStats!.uniqueUsers.toString(),
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
                    value: _wishlistStats!.itemsWithNotes.toString(),
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
                    value: _wishlistStats!.mostWishlistedCount.toString(),
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
            _buildPopularWishlistProductsSection(),
          ],
        ),
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

  Widget _buildPopularWishlistProductsSection() {
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
            'Added ${_wishlistStats?.totalItems ?? 0} items to wishlist this month',
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

  // Rest of your existing methods remain the same...
  Widget _buildOverviewSection() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {},
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'This Week',
                      child: Text('This Week'),
                    ),
                    const PopupMenuItem(
                      value: 'Last 2 weeks',
                      child: Text('Last 2 weeks'),
                    ),
                  ],
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'Last 2 weeks',
                          style: TextStyle(color: Colors.black54),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_drop_down, size: 25),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: _buildStatCard(
                      icon: Icons.people,
                      title: 'Customers',
                      value: '1024',
                      change: '-3.7%',
                      isPositive: false,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 180,
                    child: _buildStatCard(
                      icon: Icons.trending_up,
                      title: 'Income',
                      value: '256k',
                      change: '+37%',
                      isPositive: true,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Welcomed 857 customers in Readium',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Row(
                    children: List.generate(3, (index) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmQHSox6pn1Flifa00Ulnv5BWDDu0aLPF2-Q&s',
                        ),
                      ),
                    )),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View all'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey[600])),
              const Spacer(),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistSection() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Product WishList Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Last 7 days'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGetMoreCustomersSection() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Get more customers!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '50% of new customers explore products because the author sharing the work on the social media network. Gain your earnings right now! 🔥',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildSocialButton('Facebook', Icons.facebook),
                const SizedBox(width: 12),
                _buildSocialButton('Instagram', Icons.camera_alt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String name, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(name),
          ],
        ),
      ),
    );
  }

  Widget buildAllCommentsCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'customer Comments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: (){}, child: Text("View All"))
              ],
            ),
            const SizedBox(height: 24),
            ...comments.map((comment) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1494790108755?w=100&h=100&fit=crop&crop=face',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  comment.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  comment.handle,
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const Spacer(),
                                Text(
                                  comment.time,
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'On ${comment.project}',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(comment.message),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                                Icon(Icons.favorite_outline, size: 16, color: Colors.grey),
                                Icon(Icons.share_outlined, size: 16, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (comment != comments.last) const Divider(height: 20),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

Widget _buildPopularProductsCard() {
  final List<Map<String, dynamic>> products = [
    {
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTSv6X9UGTUo8go8VpZhcjJNlweqs3w7V47tu8vYyg3KRIX8gmWxiMDn_nqnyKA_l3DP4&usqp=CAU',
      'name': 'Crypter - NFT UI kit',
      'earning': '\$2,453.80',
      'status': 'Active',
    },
    {
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwfxxOhA_yMmB5rGNdo4o58AEso6thj2q63g&s',
      'name': 'Bento Matte 3D',
      'earning': '\$105.60',
      'status': 'Deactivate',
    },
    {
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSE3NgKT-z2olYZ842XQ5OXOMssPhMf7nrePg&s',
      'name': 'Excellent material 3D',
      'earning': '\$648.60',
      'status': 'Active',
    },
    {
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSE3NgKT-z2olYZ842XQ5OXOMssPhMf7nrePg&s',
      'name': 'Fleet - travel shopping kit',
      'earning': '\$649.40',
      'status': 'Active',
    },
  ];

  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Popular products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...products.map((product) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['earning'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: product['status'] == 'Active'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product['status'],
                    style: TextStyle(
                      color: product['status'] == 'Active'
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ),
  );
}

// Keep all your existing classes
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem(this.icon, this.activeIcon, this.label);
}

class Product {
  final String name;
  final String price;
  final String status;
  final Color color;

  Product(this.name, this.price, this.status, this.color);
}

class Comment {
  final String name;
  final String handle;
  final String time;
  final String project;
  final String message;

  Comment({
    required this.name,
    required this.handle,
    required this.time,
    required this.project,
    required this.message,
  });
}

final List<Comment> comments = [
  Comment(name: 'Talha', handle: '@talha', time: '2h', project: 'Car Booking', message: 'Very nice UI!'),
  Comment(name: 'Sara', handle: '@sara', time: '1h', project: 'Car Sales', message: 'Impressive structure.'),
];