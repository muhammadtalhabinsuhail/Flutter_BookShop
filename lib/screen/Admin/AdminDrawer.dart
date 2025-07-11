import 'package:flutter/material.dart';
import 'package:project/screen/Admin/AddProduct/AddProductView.dart';
import 'package:project/screen/Admin/AdminDashboard/AdminDashboardView.dart';
import 'package:project/screen/Admin/UsersList/customer_lists_screen.dart';
import 'package:project/screen/customers/Home/home_view.dart';
import 'AllOrders/all_orders_screen.dart';
import 'AreaManagementScreen/area_management_screen.dart';
import 'Catagory/category_management_screen.dart';
import 'WishList/wishlist_management_screen.dart';


class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem(this.icon, this.activeIcon, this.label);
}

class AdminDrawer extends StatefulWidget {
  final bool isDarkMode;
  final int selectedNavIndex;

  const AdminDrawer({
    super.key,
    required this.isDarkMode,
    required this.selectedNavIndex,
  });

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  late bool _isDarkMode;
  late int _selectedNavIndex;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _selectedNavIndex = widget.selectedNavIndex;
  }

  final List<NavItem> _navItems = [
    NavItem(Icons.home_outlined, Icons.home, 'Home'),
    NavItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Products'),
    NavItem(Icons.category_outlined, Icons.category, 'Category'),
    NavItem(Icons.favorite_outline, Icons.favorite, 'Wishlist'),
    NavItem(Icons.store_outlined, Icons.store, 'Shop'),
    NavItem(Icons.people_outlined, Icons.people, 'Customers'),
    NavItem(Icons.campaign_outlined, Icons.campaign, 'Promote'),
    NavItem(Icons.shopping_bag_outlined, Icons.shopping_bag, 'Orders'), // NEW ORDERS ITEM
    NavItem(Icons.location_city_outlined, Icons.location_city, 'Areas'), // NEW AREAS ITEM
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Header
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

          // Navigation
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
                      color: isSelected ? Colors.blue[600] : Colors.grey[600],
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? Colors.blue[600] : Colors.grey[700],
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

                      Navigator.pop(context); // Close drawer first

                      switch (index) {
                        case 0:
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminDashboard(selectedIndex: 0),
                            ),
                          );
                          break;
                        case 1:
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductFormPage(selectedIndex: 1),
                            ),
                          );
                          break;
                        case 2:
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryManagementScreen(),
                            ),
                          );
                          break;
                        case 3:
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WishlistManagementScreen(selectedIndex: 3),
                            ),
                          );
                          break;
                        case 4:
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(),
                            ),
                          );
                          break;
                        case 5:
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomerListsScreen(selectedIndex: 5),
                            ),
                          );
                          break;
                        case 6:
                        // Promote functionality
                          break;
                        case 7: // NEW ORDERS CASE
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllOrdersScreen(selectedIndex: 7),
                            ),
                          );
                          break;
                        case 8: // NEW AREAS CASE
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AreaManagementScreen(selectedIndex: 8),
                            ),
                          );
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
                _buildThemeButton(isDark: false, label: 'Light', icon: Icons.light_mode),
                const SizedBox(width: 8),
                _buildThemeButton(isDark: true, label: 'Dark', icon: Icons.dark_mode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton({required bool isDark, required String label, required IconData icon}) {
    final isSelected = _isDarkMode == isDark;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDarkMode = isDark;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}