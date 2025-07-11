import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/ProductModel.dart';
import 'package:project/screen/model/orders_model.dart';
import 'package:project/screen/model/selected_area_model.dart';
import 'package:project/screen/model/user_info_model.dart';
import 'package:project/screen/model/user_model.dart';
import '../UpdateOrderStatus/update_order_status_screen.dart';


class OrderDetailsScreen extends StatefulWidget {
  final OrdersModel order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  ProductModel? _product;
  UserModel? _user;
  UserInfoModel? _userInfo;
  SelectedAreaModel? _selectedArea;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      // Load product details
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('Books')
          .doc(widget.order.productId)
          .get();
      
      if (productDoc.exists) {
        _product = ProductModel.fromSnapshot(productDoc);
      }

      // Load user details
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.order.userId)
          .get();
      
      if (userDoc.exists) {
        _user = UserModel.fromSnapshot(userDoc);
      }

      // Load user info (delivery details)
      QuerySnapshot userInfoQuery = await FirebaseFirestore.instance
          .collection('UserInfo')
          .where('userId', isEqualTo: widget.order.userId)
          .orderBy('FieldValue.serverTimestamp()', descending: true)
          .limit(1)
          .get();

      if (userInfoQuery.docs.isNotEmpty) {
        _userInfo = UserInfoModel.fromSnapshot(userInfoQuery.docs.first);
        
        // Load selected area
        if (_userInfo!.selectedAreaId.isNotEmpty) {
          DocumentSnapshot areaDoc = await FirebaseFirestore.instance
              .collection('SelectedArea')
              .doc(_userInfo!.selectedAreaId)
              .get();
          
          if (areaDoc.exists) {
            _selectedArea = SelectedAreaModel.fromSnapshot(areaDoc);
          }
        }
      }

    } catch (e) {
      print('Error loading order details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading order details: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        title: Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateOrderStatusScreen(order: widget.order),
                ),
              );
            },
            tooltip: 'Update Status',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[600]))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(),
                  SizedBox(height: 16),
                  _buildProductDetails(),
                  SizedBox(height: 16),
                  _buildCustomerDetails(),
                  SizedBox(height: 16),
                  _buildDeliveryDetails(),
                  SizedBox(height: 16),
                  _buildPaymentDetails(),
                  if (widget.order.notes != null && widget.order.notes!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    _buildNotesSection(),
                  ],
                  SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Order #${widget.order.orderId}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                _buildStatusChip(widget.order.orderStatus),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Order Date: ${_formatDate(widget.order.orderDate)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (widget.order.deliveryDate != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.local_shipping, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Delivery Date: ${_formatDate(widget.order.deliveryDate!)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 12),
            if (_product != null) ...[
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _product!.imgurl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(Icons.image),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _product!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _product!.description,
                          style: TextStyle(color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Price: \$${_product!.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text('Product information not available'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'customer Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 12),
            if (_user != null) ...[
              _buildDetailRow(Icons.person, 'Name', _user!.userName),
              _buildDetailRow(Icons.email, 'Email', _user!.email),
              if (_userInfo != null)
                _buildDetailRow(Icons.phone, 'Phone', _userInfo!.phone),
            ] else ...[
              Text('customer information not available'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 12),
            if (_userInfo != null) ...[
              if (_selectedArea != null)
                _buildDetailRow(Icons.location_city, 'Area', _selectedArea!.area),
              _buildDetailRow(Icons.location_on, 'Address', _userInfo!.deliveryAddress),
            ] else ...[
              Text('Delivery information not available'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 12),
            _buildDetailRow(Icons.payment, 'Method', widget.order.paymentMethod),
            _buildDetailRow(Icons.account_balance_wallet, 'Status', widget.order.paymentStatus),
            SizedBox(height: 8),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${widget.order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'customer Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Text(
                widget.order.notes!,
                style: TextStyle(color: Colors.orange[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateOrderStatusScreen(order: widget.order),
                ),
              );
            },
            icon: Icon(Icons.edit),
            label: Text('Update Status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement print functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Print functionality coming soon')),
              );
            },
            icon: Icon(Icons.print),
            label: Text('Print Order'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[600],
              side: BorderSide(color: Colors.blue[600]!),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}