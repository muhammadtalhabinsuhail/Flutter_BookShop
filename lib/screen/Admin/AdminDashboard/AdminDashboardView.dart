// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:project/screen/Admin/WishList/admin_wishlist_controller.dart';
//
// import '../AdminDrawer.dart';
//
// class AdminDashboard extends StatefulWidget {
//   final int selectedIndex;
//   const AdminDashboard({super.key, required this.selectedIndex});
//
//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }
//
// class _AdminDashboardState extends State<AdminDashboard> {
//   bool _isDarkMode = false;
//   int _selectedNavIndex = 0;
//
//   // Wishlist Controller
//   final AdminWishlistController _wishlistController = AdminWishlistController();
//   WishlistStats? _wishlistStats;
//   bool _isLoadingWishlist = true;
//
//   final List<NavItem> _navItems = [
//     NavItem(Icons.home_outlined, Icons.home, 'Home'),
//     NavItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Products'),
//     NavItem(Icons.people_outline, Icons.people, 'Customers'),
//     NavItem(Icons.store_outlined, Icons.store, 'Shop'),
//     NavItem(Icons.trending_up_outlined, Icons.trending_up, 'Income'),
//     NavItem(Icons.campaign_outlined, Icons.campaign, 'Promote'),
//   ];
//
//   final List<Product> _popularProducts = [
//     Product('Crypter - NFT UI kit', '\$2,453.80', 'Active', Colors.orange),
//     Product('Bento Matte 3D illustration 1.0', '\$105.60', 'Inactive', Colors.pink),
//     Product('Excellent material 3D chair', '\$648.60', 'Active', Colors.blue),
//     Product('Fleet - travel shopping kit', '\$648.60', 'Active', Colors.purple),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadWishlistData();
//   }
//
//   Future<void> _loadWishlistData() async {
//     try {
//       final stats = await _wishlistController.getWishlistStats();
//       setState(() {
//         _wishlistStats = stats;
//         _isLoadingWishlist = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoadingWishlist = false;
//       });
//       print('Error loading wishlist data: $e');
//     }
//   }
//
//   ThemeData get _lightTheme => ThemeData(
//     brightness: Brightness.light,
//     scaffoldBackgroundColor: Colors.white,
//     cardColor: Colors.white,
//     primaryColor: Colors.blue,
//   );
//
//   ThemeData get _darkTheme => ThemeData(
//     brightness: Brightness.dark,
//     scaffoldBackgroundColor: Colors.grey[900],
//     cardColor: Colors.black,
//     primaryColor: Colors.blue,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: _isDarkMode ? _darkTheme : _lightTheme,
//       home: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.blue[600],
//           foregroundColor: Colors.white,
//           title: Container(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 100),
//               child: Row(
//                 children: [
//                   Text("Product Management")
//                 ],
//               ),
//             ),
//           ),
//           centerTitle: true,
//         ),
//         drawer: AdminDrawer(
//           isDarkMode: _isDarkMode,
//           selectedNavIndex: widget.selectedIndex,
//         ),
//         body: Row(
//           children: [
//             Expanded(
//               flex: 3,
//               child: _buildMainContent(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMainContent() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             children: [
//               const SizedBox(width: 16),
//               //Search Box
//               Expanded(
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Search product',
//                     prefixIcon: Icon(Icons.search, size: 20),
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(15),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: EdgeInsets.symmetric(vertical: 12),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               //Bell Icon
//               IconButton(
//                 onPressed: () {},
//                 icon: const Icon(Icons.notifications_outlined),
//               ),
//               const SizedBox(width: 8),
//               //Profile Picture
//               const CircleAvatar(
//                 radius: 16,
//                 backgroundImage: NetworkImage(
//                   'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 20),
//
//           // Dashboard Title
//           const Text(
//             'Admin Controls',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//
//           const SizedBox(height: 15),
//
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Overview Section
//                   _buildOverviewSection(),
//                   const SizedBox(height: 24),
//
//                   // Wishlist Analytics Section
//                   _buildWishlistAnalyticsSection(),
//                   const SizedBox(height: 24),
//
//                   // Charts Section
//                   _buildWishlistSection(),
//                   const SizedBox(height: 24),
//
//                   _buildPopularProductsCard(),
//                   const SizedBox(height: 24),
//
//                   // Get More Customers Section
//                   _buildGetMoreCustomersSection(),
//                   const SizedBox(height: 16),
//
//                   buildAllCommentsCard(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildWishlistAnalyticsSection() {
//     if (_isLoadingWishlist) {
//       return Card(
//         color: Colors.white,
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Container(
//           height: 200,
//           child: Center(
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
//             ),
//           ),
//         ),
//       );
//     }
//
//     if (_wishlistStats == null) return const SizedBox.shrink();
//
//     return Card(
//       color: Colors.white,
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Section Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 4,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         color: Colors.orange.shade400,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Wishlist Overview',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey.shade800,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'Last 30 days',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Icon(
//                         Icons.keyboard_arrow_down,
//                         size: 16,
//                         color: Colors.grey.shade600,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 16),
//
//             // Stats Grid
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildCompactStatCard(
//                     title: 'Total Items',
//                     value: _wishlistStats!.totalItems.toString(),
//                     icon: Icons.favorite_outline,
//                     color: Colors.blue.shade400,
//                     backgroundColor: Colors.blue.shade50,
//                     changePercent: '+12.5%',
//                     isPositive: true,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildCompactStatCard(
//                     title: 'Active Users',
//                     value: _wishlistStats!.uniqueUsers.toString(),
//                     icon: Icons.people_outline,
//                     color: Colors.purple.shade400,
//                     backgroundColor: Colors.purple.shade50,
//                     changePercent: '+8.2%',
//                     isPositive: true,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 12),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildCompactStatCard(
//                     title: 'With Notes',
//                     value: _wishlistStats!.itemsWithNotes.toString(),
//                     icon: Icons.note_outlined,
//                     color: Colors.green.shade400,
//                     backgroundColor: Colors.green.shade50,
//                     changePercent: '+5.1%',
//                     isPositive: true,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildCompactStatCard(
//                     title: 'Top Product',
//                     value: _wishlistStats!.mostWishlistedCount.toString(),
//                     icon: Icons.trending_up_outlined,
//                     color: Colors.orange.shade400,
//                     backgroundColor: Colors.orange.shade50,
//                     changePercent: '+15.3%',
//                     isPositive: true,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 16),
//
//             // Popular Products Section
//             _buildPopularWishlistProductsSection(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCompactStatCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//     required Color backgroundColor,
//     required String changePercent,
//     required bool isPositive,
//   }) {
//     return TweenAnimationBuilder<double>(
//       duration: const Duration(milliseconds: 800),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, animationValue, child) {
//         return Transform.scale(
//           scale: 0.8 + (0.2 * animationValue),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.shade200),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.shade100,
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: backgroundColor,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         icon,
//                         color: color,
//                         size: 20,
//                       ),
//                     ),
//                     const Spacer(),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: isPositive
//                             ? Colors.green.shade50
//                             : Colors.red.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             isPositive ? Icons.trending_up : Icons.trending_down,
//                             size: 12,
//                             color: isPositive
//                                 ? Colors.green.shade600
//                                 : Colors.red.shade600,
//                           ),
//                           const SizedBox(width: 2),
//                           Text(
//                             changePercent,
//                             style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600,
//                               color: isPositive
//                                   ? Colors.green.shade600
//                                   : Colors.red.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 AnimatedDefaultTextStyle(
//                   duration: const Duration(milliseconds: 600),
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade800,
//                   ),
//                   child: TweenAnimationBuilder<int>(
//                     duration: const Duration(milliseconds: 1000),
//                     tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
//                     builder: (context, animatedValue, child) {
//                       return Text(animatedValue.toString());
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade600,
//                     fontWeight: FontWeight.w500,
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
//   Widget _buildPopularWishlistProductsSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade100,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Most Wishlisted Products',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade800,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   // Navigate to full wishlist management
//                 },
//                 child: Text(
//                   'View all',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.blue.shade600,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               ...List.generate(3, (index) {
//                 return Container(
//                   margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
//                   child: _buildMiniProductCard(index),
//                 );
//               }),
//               const SizedBox(width: 8),
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Icon(
//                   Icons.add,
//                   color: Colors.grey.shade600,
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Added ${_wishlistStats?.totalItems ?? 0} items to wishlist this month',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMiniProductCard(int index) {
//     final colors = [
//       Colors.blue.shade100,
//       Colors.purple.shade100,
//       Colors.green.shade100,
//     ];
//
//     final icons = [
//       Icons.book_outlined,
//       Icons.laptop_mac_outlined,
//       Icons.phone_android_outlined,
//     ];
//
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 600 + (index * 200)),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.scale(
//           scale: value,
//           child: Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: colors[index % colors.length],
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 2),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.shade200,
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Icon(
//               icons[index % icons.length],
//               color: Colors.grey.shade700,
//               size: 20,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Rest of your existing methods remain the same...
//   Widget _buildOverviewSection() {
//     return Card(
//       color: Colors.white,
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 4,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: Colors.orange,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'Overview',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const Spacer(),
//                 PopupMenuButton<String>(
//                   onSelected: (value) {},
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(
//                       value: 'This Week',
//                       child: Text('This Week'),
//                     ),
//                     const PopupMenuItem(
//                       value: 'Last 2 weeks',
//                       child: Text('Last 2 weeks'),
//                     ),
//                   ],
//                   offset: const Offset(0, 40),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade400),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: const [
//                         Text(
//                           'Last 2 weeks',
//                           style: TextStyle(color: Colors.black54),
//                         ),
//                         SizedBox(width: 6),
//                         Icon(Icons.arrow_drop_down, size: 25),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 20),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 180,
//                     child: _buildStatCard(
//                       icon: Icons.people,
//                       title: 'Customers',
//                       value: '1024',
//                       change: '-3.7%',
//                       isPositive: false,
//                       color: Colors.blue,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   SizedBox(
//                     width: 180,
//                     child: _buildStatCard(
//                       icon: Icons.trending_up,
//                       title: 'Income',
//                       value: '256k',
//                       change: '+37%',
//                       isPositive: true,
//                       color: Colors.purple,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     'Welcomed 857 customers in Readium',
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: Row(
//                     children: List.generate(3, (index) => Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: CircleAvatar(
//                         radius: 20,
//                         backgroundImage: NetworkImage(
//                           'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmQHSox6pn1Flifa00Ulnv5BWDDu0aLPF2-Q&s',
//                         ),
//                       ),
//                     )),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {},
//                   child: const Text('View all'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatCard({
//     required IconData icon,
//     required String title,
//     required String value,
//     required String change,
//     required bool isPositive,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: color),
//               const SizedBox(width: 8),
//               Text(title, style: TextStyle(color: Colors.grey[600])),
//               const Spacer(),
//               Text(
//                 change,
//                 style: TextStyle(
//                   color: isPositive ? Colors.green : Colors.red,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildWishlistSection() {
//     return Card(
//       color: Colors.white,
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 4,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: Colors.purple,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'Product WishList Info',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const Spacer(),
//                 TextButton(
//                   onPressed: () {},
//                   child: const Text('Last 7 days'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGetMoreCustomersSection() {
//     return Card(
//       color: Colors.white,
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 4,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: Colors.blue,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'Get more customers!',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               '50% of new customers explore products because the author sharing the work on the social media network. Gain your earnings right now! 🔥',
//               style: TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 _buildSocialButton('Facebook', Icons.facebook),
//                 const SizedBox(width: 12),
//                 _buildSocialButton('Instagram', Icons.camera_alt),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSocialButton(String name, IconData icon) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey[300]!),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 16),
//             const SizedBox(width: 8),
//             Text(name),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildAllCommentsCard() {
//     return Card(
//       color: Colors.white,
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 4,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'customer Comments',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(onPressed: (){}, child: Text("View All"))
//               ],
//             ),
//             const SizedBox(height: 24),
//             ...comments.map((comment) {
//               return Column(
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CircleAvatar(
//                         radius: 16,
//                         backgroundImage: NetworkImage(
//                           'https://images.unsplash.com/photo-1494790108755?w=100&h=100&fit=crop&crop=face',
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   comment.name,
//                                   style: const TextStyle(fontWeight: FontWeight.w500),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   comment.handle,
//                                   style: TextStyle(color: Colors.grey, fontSize: 12),
//                                 ),
//                                 const Spacer(),
//                                 Text(
//                                   comment.time,
//                                   style: TextStyle(color: Colors.grey, fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               'On ${comment.project}',
//                               style: TextStyle(color: Colors.grey, fontSize: 12),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(comment.message),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
//                                 Icon(Icons.favorite_outline, size: 16, color: Colors.grey),
//                                 Icon(Icons.share_outlined, size: 16, color: Colors.grey),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (comment != comments.last) const Divider(height: 20),
//                 ],
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// Widget _buildPopularProductsCard() {
//   final List<Map<String, dynamic>> products = [
//     {
//       'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTSv6X9UGTUo8go8VpZhcjJNlweqs3w7V47tu8vYyg3KRIX8gmWxiMDn_nqnyKA_l3DP4&usqp=CAU',
//       'name': 'Crypter - NFT UI kit',
//       'earning': '\$2,453.80',
//       'status': 'Active',
//     },
//     {
//       'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwfxxOhA_yMmB5rGNdo4o58AEso6thj2q63g&s',
//       'name': 'Bento Matte 3D',
//       'earning': '\$105.60',
//       'status': 'Deactivate',
//     },
//     {
//       'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSE3NgKT-z2olYZ842XQ5OXOMssPhMf7nrePg&s',
//       'name': 'Excellent material 3D',
//       'earning': '\$648.60',
//       'status': 'Active',
//     },
//     {
//       'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSE3NgKT-z2olYZ842XQ5OXOMssPhMf7nrePg&s',
//       'name': 'Fleet - travel shopping kit',
//       'earning': '\$649.40',
//       'status': 'Active',
//     },
//   ];
//
//   return Card(
//     color: Colors.white,
//     elevation: 4,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: Colors.purple,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Popular products',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           ...products.map((product) => Padding(
//             padding: const EdgeInsets.only(bottom: 16.0),
//             child: Row(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(
//                     product['image'],
//                     width: 50,
//                     height: 50,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         product['name'],
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         product['earning'],
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 13,
//                           color: Colors.black54,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: product['status'] == 'Active'
//                         ? Colors.green.shade100
//                         : Colors.red.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     product['status'],
//                     style: TextStyle(
//                       color: product['status'] == 'Active'
//                           ? Colors.green.shade700
//                           : Colors.red.shade700,
//                       fontWeight: FontWeight.w500,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )),
//         ],
//       ),
//     ),
//   );
// }
//
// // Keep all your existing classes
// class NavItem {
//   final IconData icon;
//   final IconData activeIcon;
//   final String label;
//
//   NavItem(this.icon, this.activeIcon, this.label);
// }
//
// class Product {
//   final String name;
//   final String price;
//   final String status;
//   final Color color;
//
//   Product(this.name, this.price, this.status, this.color);
// }
//
// class Comment {
//   final String name;
//   final String handle;
//   final String time;
//   final String project;
//   final String message;
//
//   Comment({
//     required this.name,
//     required this.handle,
//     required this.time,
//     required this.project,
//     required this.message,
//   });
// }
//
// final List<Comment> comments = [
//   Comment(name: 'Talha', handle: '@talha', time: '2h', project: 'Car Booking', message: 'Very nice UI!'),
//   Comment(name: 'Sara', handle: '@sara', time: '1h', project: 'Car Sales', message: 'Impressive structure.'),
// ];




import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project/screen/Admin/WishList/admin_wishlist_controller.dart';
import 'AdminDashboardController.dart';
import '../AdminDrawer.dart';

class AdminDashboard extends StatefulWidget {
  final int selectedIndex;
  const AdminDashboard({super.key, required this.selectedIndex});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
  bool _isDarkMode = false;

  // Controllers
  final AdminDashboardController _dashboardController = AdminDashboardController();
  final AdminWishlistController _wishlistController = AdminWishlistController();

  // Data
  DashboardStats? _dashboardStats;
  UserAnalytics? _userAnalytics;
  ProductAnalytics? _productAnalytics;
  OrderAnalytics? _orderAnalytics;
  RevenueAnalytics? _revenueAnalytics;
  WishlistStats? _wishlistStats;

  // Loading states
  bool _isLoadingDashboard = true;
  bool _isLoadingUsers = true;
  bool _isLoadingProducts = true;
  bool _isLoadingOrders = true;
  bool _isLoadingRevenue = true;
  bool _isLoadingWishlist = true;

  // Animation controllers
  late AnimationController _mainAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _chartAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAllData();
  }

  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _chartAnimationController, curve: Curves.elasticOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _mainAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _cardAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _chartAnimationController.forward();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadDashboardStats(),
      _loadUserAnalytics(),
      _loadProductAnalytics(),
      _loadOrderAnalytics(),
      _loadRevenueAnalytics(),
      _loadWishlistData(),
    ]);
  }

  Future<void> _loadDashboardStats() async {
    try {
      final stats = await _dashboardController.getDashboardStats();
      setState(() {
        _dashboardStats = stats;
        _isLoadingDashboard = false;
      });
    } catch (e) {
      setState(() => _isLoadingDashboard = false);
      print('Error loading dashboard stats: $e');
    }
  }

  Future<void> _loadUserAnalytics() async {
    try {
      final analytics = await _dashboardController.getUserAnalytics();
      setState(() {
        _userAnalytics = analytics;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() => _isLoadingUsers = false);
      print('Error loading user analytics: $e');
    }
  }

  Future<void> _loadProductAnalytics() async {
    try {
      final analytics = await _dashboardController.getProductAnalytics();
      setState(() {
        _productAnalytics = analytics;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
      print('Error loading product analytics: $e');
    }
  }

  Future<void> _loadOrderAnalytics() async {
    try {
      final analytics = await _dashboardController.getOrderAnalytics();
      setState(() {
        _orderAnalytics = analytics;
        _isLoadingOrders = false;
      });
    } catch (e) {
      setState(() => _isLoadingOrders = false);
      print('Error loading order analytics: $e');
    }
  }

  Future<void> _loadRevenueAnalytics() async {
    try {
      final analytics = await _dashboardController.getRevenueAnalytics();
      setState(() {
        _revenueAnalytics = analytics;
        _isLoadingRevenue = false;
      });
    } catch (e) {
      setState(() => _isLoadingRevenue = false);
      print('Error loading revenue analytics: $e');
    }
  }

  Future<void> _loadWishlistData() async {
    try {
      final stats = await _wishlistController.getWishlistStats();
      setState(() {
        _wishlistStats = stats;
        _isLoadingWishlist = false;
      });
    } catch (e) {
      setState(() => _isLoadingWishlist = false);
      print('Error loading wishlist data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[50],
        cardColor: Colors.white,
        primaryColor: Colors.blue[600],
      ),
      home: Scaffold(
        appBar: _buildAppBar(),
        drawer: AdminDrawer(
          isDarkMode: _isDarkMode,
          selectedNavIndex: widget.selectedIndex,
        ),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      elevation: 0,
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.dashboard_outlined, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Admin Dashboard",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: _loadAllData,
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Refresh Data',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(constraints.maxWidth > 1200 ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                _buildHeader(),
                const SizedBox(height: 24),



                _buildAnalyticsSection(),
                const SizedBox(height: 24),
                _buildChartsSection(),
                const SizedBox(height: 24),
                _buildRecentActivitiesSection(),
                const SizedBox(height: 24),

                _buildMainStatsGrid(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isCompact = constraints.maxWidth < 600;

          return Container(
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: isCompact
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderContent(isCompact),
                const SizedBox(height: 16),
                Center(child: _buildHeaderIcon()),
              ],
            )
                : Row(
              children: [
                Expanded(child: _buildHeaderContent(isCompact)),
                _buildHeaderIcon(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderContent(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Welcome to Admin Dashboard',
            style: TextStyle(
              fontSize: isCompact ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Monitor your business performance and analytics',
          style: TextStyle(
            fontSize: isCompact ? 14 : 16,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Last updated: ${DateTime.now().toString().substring(0, 16)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.analytics_outlined,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMainStatsGrid() {
    if (_isLoadingDashboard || _dashboardStats == null) {
      return _buildLoadingGrid();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive grid
          int crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth, 280);
          double childAspectRatio = _calculateAspectRatio(constraints.maxWidth, crossAxisCount);

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
            children: [
              _buildAnimatedStatCard(
                title: 'Total Users',
                value: _dashboardStats!.totalUsers.toString(),
                icon: Icons.people_outline,
                color: Colors.blue[600]!,
                backgroundColor: Colors.blue[50]!,
                changePercent: _userAnalytics?.growthRate.toStringAsFixed(1) ?? '0',
                isPositive: (_userAnalytics?.growthRate ?? 0) >= 0,
              ),
              _buildAnimatedStatCard(
                title: 'Total Products',
                value: _dashboardStats!.totalProducts.toString(),
                icon: Icons.inventory_2_outlined,
                color: Colors.green[600]!,
                backgroundColor: Colors.green[50]!,
                changePercent: '+12.5',
                isPositive: true,
              ),
              _buildAnimatedStatCard(
                title: 'Total Orders',
                value: _dashboardStats!.totalOrders.toString(),
                icon: Icons.shopping_cart_outlined,
                color: Colors.orange[600]!,
                backgroundColor: Colors.orange[50]!,
                changePercent: '+8.3',
                isPositive: true,
              ),
              _buildAnimatedStatCard(
                title: 'Revenue',
                value: '\$${_dashboardStats!.totalRevenue.toStringAsFixed(0)}',
                icon: Icons.attach_money_outlined,
                color: Colors.purple[600]!,
                backgroundColor: Colors.purple[50]!,
                changePercent: _revenueAnalytics?.growthRate.toStringAsFixed(1) ?? '0',
                isPositive: (_revenueAnalytics?.growthRate ?? 0) >= 0,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth, 280);
        double childAspectRatio = _calculateAspectRatio(constraints.maxWidth, crossAxisCount);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: List.generate(4, (index) => _buildLoadingCard()),
        );
      },
    );
  }

  int _calculateCrossAxisCount(double width, double minCardWidth) {
    int count = (width / minCardWidth).floor();
    return count < 1 ? 1 : (count > 4 ? 4 : count);
  }

  double _calculateAspectRatio(double width, int crossAxisCount) {
    double cardWidth = (width - (16 * (crossAxisCount - 1))) / crossAxisCount;
    return cardWidth / 200; // Desired card height
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String changePercent,
    required bool isPositive,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animationValue),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isCompact = constraints.maxWidth < 200;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isCompact ? 8 : 12),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: isCompact ? 20 : 24),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isPositive ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPositive ? Icons.trending_up : Icons.trending_down,
                                  size: 10,
                                  color: isPositive ? Colors.green[600] : Colors.red[600],
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${changePercent}%',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: isPositive ? Colors.green[600] : Colors.red[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isCompact ? 12 : 16),
                    Flexible(
                      child: TweenAnimationBuilder<int>(
                        duration: const Duration(milliseconds: 1500),
                        tween: IntTween(begin: 0, end: int.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0),
                        builder: (context, animatedValue, child) {
                          String displayValue = value.contains('\$')
                              ? '\$${animatedValue.toString()}'
                              : animatedValue.toString();
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              displayValue,
                              style: TextStyle(
                                fontSize: isCompact ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: isCompact ? 6 : 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: isCompact ? 12 : 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            // Stack vertically on smaller screens
            return Column(
              children: [
                _buildUserAnalyticsCard(),
                const SizedBox(height: 16),
                _buildProductAnalyticsCard(),
                const SizedBox(height: 16),
                _buildOrderAnalyticsCard(),
              ],
            );
          } else {
            // Use Row on larger screens
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildUserAnalyticsCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildProductAnalyticsCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildOrderAnalyticsCard()),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildUserAnalyticsCard() {
    if (_isLoadingUsers || _userAnalytics == null) {
      return _buildLoadingAnalyticsCard('User Analytics');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'User Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMiniStatRow(
            'New This Month',
            _userAnalytics!.newUsersThisMonth.toString(),
            Icons.person_add_outlined,
            Colors.blue[600]!,
          ),
          const SizedBox(height: 12),
          _buildMiniStatRow(
            'Admin Users',
            _userAnalytics!.adminUsers.toString(),
            Icons.admin_panel_settings_outlined,
            Colors.purple[600]!,
          ),
          const SizedBox(height: 12),
          _buildMiniStatRow(
            'Customers',
            _userAnalytics!.customerUsers.toString(),
            Icons.people_outline,
            Colors.green[600]!,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue[600], size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Growth: ${_userAnalytics!.growthRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductAnalyticsCard() {
    if (_isLoadingProducts || _productAnalytics == null) {
      return _buildLoadingAnalyticsCard('Product Analytics');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Product Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMiniStatRow(
            'Low Stock',
            _productAnalytics!.lowStockProducts.toString(),
            Icons.warning_outlined,
            Colors.orange[600]!,
          ),
          const SizedBox(height: 12),
          _buildMiniStatRow(
            'Out of Stock',
            _productAnalytics!.outOfStockProducts.toString(),
            Icons.error_outline,
            Colors.red[600]!,
          ),
          const SizedBox(height: 12),
          _buildMiniStatRow(
            'Avg Price',
            '\$${_productAnalytics!.averagePrice.toStringAsFixed(0)}',
            Icons.attach_money_outlined,
            Colors.green[600]!,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_outlined, color: Colors.green[600], size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Value: \$${_productAnalytics!.totalInventoryValue.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderAnalyticsCard() {
    if (_isLoadingOrders || _orderAnalytics == null) {
      return _buildLoadingAnalyticsCard('Order Analytics');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Order Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMiniStatRow(
            'Today',
            _orderAnalytics!.todayOrders.toString(),
            Icons.today_outlined,
            Colors.blue[600]!,
          ),
          const SizedBox(height: 12),
          _buildMiniStatRow(
            'This Week',
            _orderAnalytics!.weekOrders.toString(),
            Icons.date_range_outlined,
            Colors.purple[600]!,
          ),
          const SizedBox(height: 12),
          _buildMiniStatRow(
            'This Month',
            _orderAnalytics!.monthOrders.toString(),
            Icons.calendar_month_outlined,
            Colors.green[600]!,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.monetization_on_outlined, color: Colors.orange[600], size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Today: \$${_orderAnalytics!.todayRevenue.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAnalyticsCard(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 20),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 1000) {
            // Stack vertically on smaller screens
            return Column(
              children: [
                _buildRevenueChart(),
                const SizedBox(height: 16),
                _buildOrderStatusChart(),
              ],
            );
          } else {
            // Use Row on larger screens
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: _buildRevenueChart()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildOrderStatusChart()),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildRevenueChart() {
    if (_isLoadingRevenue || _revenueAnalytics == null) {
      return _buildLoadingChart('Revenue Trend');
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
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
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Revenue Trend (Last 30 Days)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 2.0,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _revenueAnalytics!.dailyRevenue.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue[600],
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue[600]!.withOpacity(0.1),
                      ),
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

  Widget _buildOrderStatusChart() {
    if (_isLoadingOrders || _orderAnalytics == null) {
      return _buildLoadingChart('Order Status');
    }

    final statusData = _orderAnalytics!.statusBreakdown;
    final colors = [
      Colors.blue[600]!,
      Colors.green[600]!,
      Colors.orange[600]!,
      Colors.purple[600]!,
      Colors.red[600]!,
    ];

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
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
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Order Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.0,
              child: PieChart(
                PieChartData(
                  sections: statusData.entries.map((entry) {
                    final index = statusData.keys.toList().indexOf(entry.key);
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      color: colors[index % colors.length],
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: statusData.entries.map((entry) {
                final index = statusData.keys.toList().indexOf(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingChart(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 40),
          AspectRatio(
            aspectRatio: 1.5,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            // Stack vertically on smaller screens
            return Column(
              children: [
                _buildRecentOrdersCard(),
                const SizedBox(height: 16),
                _buildWishlistOverviewCard(),
              ],
            );
          } else {
            // Use Row on larger screens
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildRecentOrdersCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildWishlistOverviewCard()),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    if (_isLoadingOrders || _orderAnalytics == null) {
      return _buildLoadingActivityCard('Recent Orders');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.purple[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(color: Colors.blue[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_orderAnalytics!.recentOrders.take(5).map((order) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: _getStatusColor(order.orderStatus),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Order #${order.orderId.substring(0, 8)}...',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          order.orderStatus,
                          style: TextStyle(
                            color: _getStatusColor(order.orderStatus),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildWishlistOverviewCard() {
    if (_isLoadingWishlist || _wishlistStats == null) {
      return _buildLoadingActivityCard('Wishlist Overview');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.pink[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Wishlist Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMiniStatRow(
            'Total Items',
            _wishlistStats!.totalItems.toString(),
            Icons.favorite_outline,
            Colors.pink[600]!,
          ),
          const SizedBox(height: 12),
          _buildMiniStatRow(
            'Unique Users',
            _wishlistStats!.uniqueUsers.toString(),
            Icons.people_outline,
            Colors.blue[600]!,
          ),
          const SizedBox(height: 12),
          _buildMiniStatRow(
            'With Notes',
            _wishlistStats!.itemsWithNotes.toString(),
            Icons.note_outlined,
            Colors.green[600]!,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.pink[600], size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Most Wishlisted: ${_wishlistStats!.mostWishlistedCount} items',
                      style: TextStyle(
                        color: Colors.pink[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingActivityCard(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 40),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange[600]!;
      case 'approved':
        return Colors.blue[600]!;
      case 'processing':
        return Colors.purple[600]!;
      case 'shipped':
        return Colors.indigo[600]!;
      case 'delivered':
        return Colors.green[600]!;
      case 'cancelled':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _cardAnimationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }
}
