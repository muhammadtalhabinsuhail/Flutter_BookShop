import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:project/Screens/Admin/AddProduct/AddProductView.dart';
import 'package:project/Screens/Customer/Home/HomeView.dart';

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
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 100),
              child: Row(

                children: [
                  Image.asset("logo.png",height: 45,),
                  SizedBox(width: 10,),
                  Text("Readium")
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
            // Right Sidebar
           // _buildRightSidebar(),
          ],
        ),
      ),
    );
  }



  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: const Icon(Icons.apps, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Admin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = index == _selectedNavIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: ListTile(
                    leading: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? Colors.blue : Colors.grey[100],
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: Colors.blue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedNavIndex = index;
                      });

                      // ✅ Navigation logic here:
                      switch (index) {
                        case 0:
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboard(selectedIndex: 0,)));
                          break;
                        case 1:
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductFormPage(selectedIndex:3)));
                          break;
                        case 2:
                         // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsScreen()));
                          break;
                        case 3:
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                          break;
                        case 4:
                         // Navigator.push(context, MaterialPageRoute(builder: (context) => IncomeScreen()));
                          break;
                        case 5:
                         //  Navigator.push(context, MaterialPageRoute(builder: (context) => PromoteScreen()));
                          break;
                      }
                    },

                    trailing: index == 1 ? const Icon(Icons.add, size: 16) : null,
                  ),
                );
              },
            ),
          ),

          // Help Section
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.blue),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Help & getting started',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '8',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Theme Toggle
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDarkMode = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isDarkMode ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.light_mode,
                          size: 16,
                          color: !_isDarkMode ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Light',
                          style: TextStyle(
                            color: !_isDarkMode ? Colors.white : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDarkMode = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.dark_mode,
                          size: 16,
                          color: _isDarkMode ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Dark',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
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

                  // Charts Section
                  _buildChartsSection(),
                  const SizedBox(height: 24),

                  _buildPopularProductsCard(),
                  const SizedBox(height: 24),
                  // Get More Customers Section



                  _buildGetMoreCustomersSection(),
                  const SizedBox(height: 16),

                  buildAllCommentsCard(),
                 // ...comments.map((comment) => _buildCommentItem(comment)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildOverviewSection() {
    return Card(
        color: Colors.white, // Set the background color to white
        elevation: 4, // Optional: adds shadow to give it depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Optional: rounded corners
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

                // ✅ STATIC DROPDOWN HERE
                PopupMenuButton<String>(
                  onSelected: (value) {
                    // Handle selected value
                  },
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
                    width: 180, // fixed width for the card (adjust as needed)
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

  Widget _buildChartsSection() {
    return Card(
      color: Colors.white, // Set the background color to white
      elevation: 4, // Optional: adds shadow to give it depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Optional: rounded corners
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
                  'Product views',
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
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 30,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${22 + value.toInt()}');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 25, color: Colors.green.shade300)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 20, color: Colors.orange.shade300)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 28, color: Colors.blue)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 18, color: Colors.green.shade300)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 26, color: Colors.green.shade300)]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 15, color: Colors.orange.shade300)]),
                    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 22, color: Colors.green.shade300)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildGetMoreCustomersSection() {
    return Card(
      color: Colors.white, // Set the background color to white
      elevation: 4, // Optional: adds shadow to give it depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Optional: rounded corners
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

  // Widget _buildRightSidebar() {
  //   return Container(
  //     width: 300,
  //     color: Theme.of(context).cardColor,
  //     child: Column(
  //       children: [
  //         // Popular Products
  //         Expanded(
  //           child: SingleChildScrollView(
  //             padding: const EdgeInsets.all(20),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Container(
  //                       width: 4,
  //                       height: 20,
  //                       decoration: BoxDecoration(
  //                         color: Colors.blue,
  //                         borderRadius: BorderRadius.circular(2),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     const Text(
  //                       'Popular products',
  //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
  //                 ..._popularProducts.map((product) => _buildProductItem(product)).toList(),
  //                 const SizedBox(height: 8),
  //                 Center(
  //                   child: TextButton(
  //                     onPressed: () {},
  //                     child: const Text('All products'),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 24),
  //
  //                 // Comments Section
  //                 Row(
  //                   children: [
  //                     Container(
  //                       width: 4,
  //                       height: 20,
  //                       decoration: BoxDecoration(
  //                         color: Colors.orange,
  //                         borderRadius: BorderRadius.circular(2),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     const Text(
  //                       'Comments',
  //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
  //                 ...comments.map((comment) => _buildCommentItem(comment)).toList(),
  //                 const SizedBox(height: 8),
  //                 Center(
  //                   child: TextButton(
  //                     onPressed: () {},
  //                     child: const Text('View all'),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 24),
  //
  //                 // Refund Requests
  //                 Row(
  //                   children: [
  //                     Container(
  //                       width: 4,
  //                       height: 20,
  //                       decoration: BoxDecoration(
  //                         color: Colors.red,
  //                         borderRadius: BorderRadius.circular(2),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     const Text(
  //                       'Refund requests',
  //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Container(
  //                   padding: const EdgeInsets.all(16),
  //                   decoration: BoxDecoration(
  //                     color: Colors.red.withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           const Icon(Icons.shopping_bag, color: Colors.red),
  //                           const SizedBox(width: 8),
  //                           const Text('You have 52 open refund'),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 4),
  //                       const Text('requests to action. This includes'),
  //                       const Text('8 new requests. 👀'),
  //                       const SizedBox(height: 12),
  //                       ElevatedButton(
  //                         onPressed: () {},
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.red,
  //                           foregroundColor: Colors.white,
  //                         ),
  //                         child: const Text('Review refund requests'),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildProductItem(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: product.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.inventory, color: product.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.price,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.status == 'Active' ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              product.status,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
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
                  'Customer Comments',
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

//   Widget _buildCommentItem(Comment comment) {
//     return Card(
//       color: Colors.white,
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//
//         child: Container(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children:[
//               Row(
//                 children: [
//                   Container(
//                     width: 4,
//                     height: 20,
//                     decoration: BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Get more customers!',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             SizedBox(height: 24,),
//             ...List.generate(comments.length, (index) {
//               final comment = comments[index];
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
//                                   style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                                 ),
//                                 const Spacer(),
//                                 Text(
//                                   comment.time,
//                                   style: TextStyle(color: Colors.grey[500], fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               'On ${comment.project}',
//                               style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(comment.message),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 IconButton(
//                                   icon: Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[600]),
//                                   onPressed: () {
//                                     // Chat icon action
//                                     print('Chat on ${comment.name}');
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: Icon(Icons.favorite_outline, size: 16, color: Colors.grey[600]),
//                                   onPressed: () {
//                                     // Like icon action
//                                     print('Like ${comment.name}');
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: Icon(Icons.share_outlined, size: 16, color: Colors.grey[600]),
//                                   onPressed: () {
//                                     // Share icon action
//                                     print('Share ${comment.name}');
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (index < comments.length - 1)
//                     const Divider(height: 20), // adds a divider between comments
//                 ],
//               );
//             }),
// ],
//           ),
//         ),
//       ),
//     );
//
//   }
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
    color: Colors.white, // Set the background color to white
    elevation: 4, // Optional: adds shadow to give it depth
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Optional: rounded corners
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
  // more comments
];
