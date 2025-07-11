import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/orders_model.dart';
import '../AdminDrawer.dart';
import '../OrderDetails/order_details_screen.dart';
import '../UpdateOrderStatus/update_order_status_screen.dart';


class AllOrdersScreen extends StatefulWidget {
  final int selectedIndex;
  
  const AllOrdersScreen({Key? key, this.selectedIndex = 7}) : super(key: key);

  @override
  _AllOrdersScreenState createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> with TickerProviderStateMixin {
  List<OrdersModel> _allOrders = [];
  List<OrdersModel> _filteredOrders = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isSelectionMode = false;
  Set<String> _selectedOrders = {};
  late TabController _tabController;

  final List<String> _filterOptions = ['All', 'Pending', 'Order Placed', 'Approved', 'Delivered'];
  final List<String> _tabLabels = ['All Orders', 'Pending', 'Approved', 'Delivered'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .orderBy('orderDate', descending: true)
          .get();

      _allOrders = OrdersModel.fromQuerySnapshot(querySnapshot);
      _applyFilter();
    } catch (e) {
      print('Error loading orders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      _filteredOrders = List.from(_allOrders);
    } else {
      _filteredOrders = _allOrders
          .where((order) => order.orderStatus == _selectedFilter)
          .toList();
    }
    setState(() {});
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedOrders.clear();
      }
    });
  }

  void _toggleOrderSelection(String orderId) {
    setState(() {
      if (_selectedOrders.contains(orderId)) {
        _selectedOrders.remove(orderId);
      } else {
        _selectedOrders.add(orderId);
      }
    });
  }

  Future<void> _bulkUpdateStatus(String newStatus) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      for (String orderId in _selectedOrders) {
        DocumentReference orderRef = FirebaseFirestore.instance
            .collection('Orders')
            .doc(orderId);
        batch.update(orderRef, {
          'orderStatus': newStatus,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedOrders.length} orders updated successfully')),
      );
      
      _toggleSelectionMode();
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating orders: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: AdminDrawer(isDarkMode: false, selectedNavIndex: widget.selectedIndex),
      body: Column(
        children: [
          // _buildTabBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.blue[600]))
                : _buildOrdersList(),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode && _selectedOrders.isNotEmpty
          ? _buildBulkActionFAB()
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      title: _isSelectionMode
          ? Text('${_selectedOrders.length} selected')
          : const Text(
              'Orders Management',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
      actions: [
        if (_isSelectionMode) ...[
          if (_selectedOrders.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: _bulkUpdateStatus,
              itemBuilder: (context) => [
                PopupMenuItem(value: 'Approved', child: Text('Mark as Approved')),
                PopupMenuItem(value: 'Delivered', child: Text('Mark as Delivered')),
                PopupMenuItem(value: 'Pending', child: Text('Mark as Pending')),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _toggleSelectionMode,
            tooltip: 'Cancel Selection',
          ),
        ] else ...[
          if (_filteredOrders.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select Multiple',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Refresh',
          ),
        ],
      ],
      bottom: _isSelectionMode ? null : TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        onTap: (index) {
          switch (index) {
            case 0:
              _selectedFilter = 'All';
              break;
            case 1:
              _selectedFilter = 'Pending';
              break;
            case 2:
              _selectedFilter = 'Approved';
              break;
            case 3:
              _selectedFilter = 'Delivered';
              break;
          }
          _applyFilter();
        },
        tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
      ),
    );
  }

  // Widget _buildTabBar() {
  //   if (_isSelectionMode) return SizedBox();
  //
  //   return Container(
  //     color: Colors.blue[600],
  //     child: TabBar(
  //       controller: _tabController,
  //       indicatorColor: Colors.white,
  //       labelColor: Colors.white,
  //       unselectedLabelColor: Colors.white70,
  //       onTap: (index) {
  //         switch (index) {
  //           case 0:
  //             _selectedFilter = 'All';
  //             break;
  //           case 1:
  //             _selectedFilter = 'Pending';
  //             break;
  //           case 2:
  //             _selectedFilter = 'Approved';
  //             break;
  //           case 3:
  //             _selectedFilter = 'Delivered';
  //             break;
  //         }
  //         _applyFilter();
  //       },
  //       tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
  //     ),
  //   );
  // }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Orders: ${_filteredOrders.length}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
          Spacer(),
          if (!_isSelectionMode)
            PopupMenuButton<String>(
              child: Chip(
                label: Text(_selectedFilter),
                avatar: Icon(Icons.filter_list, size: 18),
                backgroundColor: Colors.blue[50],
              ),
              onSelected: (value) {
                setState(() {
                  _selectedFilter = value;
                });
                _applyFilter();
              },
              itemBuilder: (context) => _filterOptions
                  .map((option) => PopupMenuItem(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Orders will appear here when customers place them',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        final isSelected = _selectedOrders.contains(order.id);
        String shortOrderId = order.orderId.substring(0, 12);

        return Card(
          color: Colors.white,
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: InkWell(
            onTap: () {
              if (_isSelectionMode) {
                _toggleOrderSelection(order.id!);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsScreen(order: order),
                  ),
                );
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelectionMode();
                _toggleOrderSelection(order.id!);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: Colors.blue[600]!, width: 2)
                    : null,
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_isSelectionMode)
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              _toggleOrderSelection(order.id!);
                            },
                            activeColor: Colors.blue[600],
                          ),
                        // Expanded(
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Expanded(
                        //             child: Text(
                        //               'Order # ${shortOrderId}',
                        //               style: TextStyle(
                        //                 fontWeight: FontWeight.bold,
                        //                 fontSize: 16,
                        //               ),
                        //
                        //             ),
                        //           ),
                        //           SizedBox(width: 12),
                        //
                        //
                        //
                        //
                        //           Flexible(
                        //             child: FittedBox(
                        //               fit: BoxFit.scaleDown,
                        //               child: _buildStatusChip(order.orderStatus),
                        //             ),
                        //           ),
                        //
                        //
                        //
                        //
                        //         ],
                        //       ),
                        //
                        //       SizedBox(height: 8),
                        //       Row(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        //           SizedBox(width: 4),
                        //           Expanded(
                        //             child: Text(
                        //               _formatDate(order.orderDate),
                        //               style: TextStyle(color: Colors.grey[600]),
                        //               overflow: TextOverflow.ellipsis,
                        //             ),
                        //           ),
                        //           SizedBox(width: 8),
                        //           FittedBox(
                        //             fit: BoxFit.scaleDown,
                        //             child: Text(
                        //               '\$${order.totalAmount.toStringAsFixed(2)}',
                        //               style: TextStyle(
                        //                 fontWeight: FontWeight.bold,
                        //                 fontSize: 16,
                        //                 color: Colors.green[600],
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //
                        //     ],
                        //   ),
                        // ),


                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left side: Order ID
                                  Expanded(
                                    child: Text(
                                      'Order # $shortOrderId',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),

                                  // Right side: Status chip
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: _buildStatusChip(order.orderStatus),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _formatDate(order.orderDate),
                                      style: TextStyle(color: Colors.grey[600]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '\$${order.totalAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (!_isSelectionMode)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'details') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetailsScreen(order: order),
                                  ),
                                );
                              } else if (value == 'update') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateOrderStatusScreen(order: order),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'details',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, size: 18),
                                    SizedBox(width: 8),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'update',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Update Status'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (order.notes != null && order.notes!.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.note, size: 16, color: Colors.orange[600]),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.notes!,
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );






  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'order placed':
        color = Colors.blue;
        icon = Icons.shopping_bag;
        break;
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'delivered':
        color = Colors.purple;
        icon = Icons.local_shipping;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      avatar: Icon(icon, size: 16, color: Colors.white),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildBulkActionFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bulk Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Mark as Approved'),
                  onTap: () {
                    Navigator.pop(context);
                    _bulkUpdateStatus('Approved');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.local_shipping, color: Colors.purple),
                  title: Text('Mark as Delivered'),
                  onTap: () {
                    Navigator.pop(context);
                    _bulkUpdateStatus('Delivered');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.pending, color: Colors.orange),
                  title: Text('Mark as Pending'),
                  onTap: () {
                    Navigator.pop(context);
                    _bulkUpdateStatus('Pending');
                  },
                ),
              ],
            ),
          ),
        );
      },
      label: Text('Actions'),
      icon: Icon(Icons.edit),
      backgroundColor: Colors.blue[600],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}