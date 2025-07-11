import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/orders_model.dart';
import 'package:project/screen/model/status_history_model.dart';

class UpdateOrderStatusScreen extends StatefulWidget {
  final OrdersModel order;

  const UpdateOrderStatusScreen({Key? key, required this.order}) : super(key: key);

  @override
  _UpdateOrderStatusScreenState createState() => _UpdateOrderStatusScreenState();
}

class _UpdateOrderStatusScreenState extends State<UpdateOrderStatusScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _deliveryDateController = TextEditingController();
  
  String _selectedOrderStatus = '';
  String _selectedPaymentStatus = '';
  DateTime? _selectedDeliveryDate;
  bool _isLoading = false;
  List<StatusHistoryModel> _statusHistory = [];

  final List<String> _orderStatusOptions = [
    'Pending',
    'Order Placed',
    'Approved',
    'Processing',
    'Shipped',
    'Out for Delivery',
    'Delivered',
    'Cancelled'
  ];

  final List<String> _paymentStatusOptions = ['Pending', 'Paid'];

  @override
  void initState() {
    super.initState();
    _selectedOrderStatus = widget.order.orderStatus;
    _selectedPaymentStatus = widget.order.paymentStatus;
    _selectedDeliveryDate = widget.order.deliveryDate;
    if (_selectedDeliveryDate != null) {
      _deliveryDateController.text = _formatDate(_selectedDeliveryDate!);
    }
    _loadStatusHistory();
  }

  Future<void> _loadStatusHistory() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('StatusHistory')
          .where('orderId', isEqualTo: widget.order.orderId)
          .orderBy('timestamp', descending: false)
          .get();

      _statusHistory = StatusHistoryModel.fromQuerySnapshot(querySnapshot);
      setState(() {});
    } catch (e) {
      print('Error loading status history: $e');
    }
  }

  Future<void> _selectDeliveryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeliveryDate ?? DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDeliveryDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          _deliveryDateController.text = _formatDate(_selectedDeliveryDate!);
        });
      }
    }
  }

  Future<void> _updateOrderStatus() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Update order
      DocumentReference orderRef = FirebaseFirestore.instance
          .collection('Orders')
          .doc(widget.order.id);

      Map<String, dynamic> updateData = {
        'orderStatus': _selectedOrderStatus,
        'paymentStatus': _selectedPaymentStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (_selectedDeliveryDate != null) {
        updateData['deliveryDate'] = _selectedDeliveryDate;
      }

      batch.update(orderRef, updateData);

      // Add status history entry
      if (_messageController.text.trim().isNotEmpty) {
        StatusHistoryModel statusHistory = StatusHistoryModel(
          status: _selectedOrderStatus,
          timestamp: DateTime.now(),
          message: _messageController.text.trim(),
          orderId: widget.order.orderId,
        );

        DocumentReference statusRef = FirebaseFirestore.instance
            .collection('StatusHistory')
            .doc();
        batch.set(statusRef, statusHistory.toMap());

        // Update order tracker
        QuerySnapshot trackerQuery = await FirebaseFirestore.instance
            .collection('OrderTracker')
            .where('orderId', isEqualTo: widget.order.orderId)
            .limit(1)
            .get();

        if (trackerQuery.docs.isNotEmpty) {
          DocumentReference trackerRef = trackerQuery.docs.first.reference;
          batch.update(trackerRef, {
            'currentStatus': _selectedOrderStatus,
            'statusHistoryId': statusRef.id,
            'lastUpdated': FieldValue.serverTimestamp(),
            if (_selectedDeliveryDate != null)
              'estimatedDelivery': _selectedDeliveryDate,
          });
        }

        if(_selectedOrderStatus == "Delivered"){

        }

      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated successfully!')),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order: $e')),
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
          'Update Order Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfo(),
              SizedBox(height: 24),
              _buildStatusUpdateForm(),
              SizedBox(height: 24),
              _buildStatusHistory(),
              SizedBox(height: 32),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Order #${widget.order.orderId}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Spacer(),
                _buildStatusChip(widget.order.orderStatus),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Total: \$${widget.order.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 16),
            
            // Order Status Dropdown
            DropdownButtonFormField<String>(
              value: _selectedOrderStatus,
              decoration: InputDecoration(
                labelText: 'Order Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
              ),
              items: _orderStatusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedOrderStatus = value!;
                });
              },
            ),
            SizedBox(height: 16),
            
            // Payment Status Dropdown
            DropdownButtonFormField<String>(
              value: _selectedPaymentStatus,
              decoration: InputDecoration(
                labelText: 'Payment Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              items: _paymentStatusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentStatus = value!;
                });
              },
            ),
            SizedBox(height: 16),
            
            // Delivery Date Picker
            TextFormField(
              controller: _deliveryDateController,
              decoration: InputDecoration(
                labelText: 'Delivery Date (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectedDeliveryDate = null;
                      _deliveryDateController.clear();
                    });
                  },
                ),
              ),
              readOnly: true,
              onTap: _selectDeliveryDate,
            ),
            SizedBox(height: 16),
            
            // Status Message
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Status Message',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
                hintText: 'Enter a message for the customer...',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a status message';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHistory() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 16),
            if (_statusHistory.isEmpty) ...[
              Center(
                child: Text(
                  'No status history available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ] else ...[
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _statusHistory.length,
                itemBuilder: (context, index) {
                  final history = _statusHistory[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(
                          color: Colors.blue[600]!,
                          width: 4,
                        ),
                      ),

                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              history.status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                            Spacer(),
                            Text(
                              _formatDate(history.timestamp),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          history.message,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
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

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateOrderStatus,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Update Order Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _deliveryDateController.dispose();
    super.dispose();
  }
}