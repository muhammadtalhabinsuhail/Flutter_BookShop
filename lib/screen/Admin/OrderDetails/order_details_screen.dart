import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/model/ProductModel.dart';
import 'package:project/screen/model/orders_model.dart';
import 'package:project/screen/model/selected_area_model.dart';
import 'package:project/screen/model/user_info_model.dart';
import 'package:project/screen/model/user_model.dart';
import '../UpdateOrderStatus/update_order_status_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
// Web-specific imports
import 'dart:html' as html;
import 'dart:convert';

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
  late String shortOrderId;

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

  Future<void> _showPrintDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadKey = 'downloaded_${widget.order.orderId}';
    final hasDownloaded = prefs.getBool(downloadKey) ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Download Order Bill',
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            hasDownloaded
                ? 'You have already downloaded this bill. Do you want to download it again?'
                : 'Do you want to download the order details as a PDF bill?',
            style: TextStyle(
              color: hasDownloaded ? Colors.black : Colors.red,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // text color
              ),
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (kIsWeb) {
                  await _generateAndDownloadPDFWeb();
                } else {
                  await _generateAndSavePDFMobile();
                }
                await prefs.setBool(downloadKey, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Yes'),
            ),
          ],
        );

      },
    );
  }

  // Web-specific PDF generation and download
  Future<void> _generateAndDownloadPDFWeb() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Generating PDF...'),
              ],
            ),
          );
        },
      );

      // Load logo from assets
      final ByteData logoData = await rootBundle.load('assets/logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with logo and shop info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Image(
                              pw.MemoryImage(logoBytes),
                              width: 40,
                              height: 40,
                            ),
                            pw.SizedBox(width: 10),
                            pw.Text(
                              'Readium',
                              style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text('Muhammad Talha Bin Suhail',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.Text('0312-3670670',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.Text('B-456 BLOCK 16 SHADAB, KARACHI',
                            style: pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text('Order #${shortOrderId}...',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.Text('Date: ${_formatDate(widget.order.orderDate)}',
                            style: pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),
                pw.Container(
                  height: 1,
                  color: PdfColors.black,
                ),
                pw.SizedBox(height: 20),

                // Customer Details
                pw.Text(
                  'CUSTOMER DETAILS',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (_user != null) ...[
                        pw.Text('Name: ${_user!.userName}',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 3),
                        pw.Text('Email: ${_user!.email}',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 3),
                        if (_userInfo != null)
                          pw.Text('Phone: ${_userInfo!.phone}',
                              style: pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 3),
                        if (_userInfo != null)
                          pw.Text('Address: ${_userInfo!.deliveryAddress}',
                              style: pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 3),
                        if (_selectedArea != null)
                          pw.Text('Area: ${_selectedArea!.area}',
                              style: pw.TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Order Details
                pw.Text(
                  'ORDER DETAILS',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                // Product table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Product',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Description',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Price',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    if (_product != null)
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(_product!.name,
                                style: pw.TextStyle(fontSize: 11)),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(_product!.description,
                                style: pw.TextStyle(fontSize: 11)),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('\$${_product!.price.toStringAsFixed(2)}',
                                style: pw.TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Payment Details
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Payment Method: ${widget.order.paymentMethod}',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 3),
                        pw.Text('Payment Status: ${widget.order.paymentStatus}',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 3),
                        pw.Text('Order Status: ${widget.order.orderStatus}',
                            style: pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    pw.Container(
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black, width: 2),
                      ),
                      child: pw.Text(
                        'Total: \$${widget.order.totalAmount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                // Footer
                pw.Center(
                  child: pw.Container(
                    padding: pw.EdgeInsets.symmetric(vertical: 10),
                    child: pw.Text(
                      'THANKS FOR SHOPPING',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Generate PDF bytes
      final Uint8List pdfBytes = await pdf.save();

      // Create blob and download for web
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'Order_${shortOrderId}_Bill.pdf';
      html.document.body!.children.add(anchor);

      // Trigger download
      anchor.click();

      // Clean up
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bill downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mobile-specific PDF generation (fallback)
  Future<void> _generateAndSavePDFMobile() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Generating PDF...'),
              ],
            ),
          );
        },
      );

      // For mobile, you can implement path_provider + share_plus logic here
      // or show a message that it's not supported on mobile web

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF generation on mobile is not implemented yet'),
          backgroundColor: Colors.orange,
        ),
      );

    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    shortOrderId = widget.order.orderId.substring(0, 10);

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

            _buildCustomerDetails(),
            SizedBox(height: 16),
            _buildProductDetails(),


            SizedBox(height: 16),
            _buildPaymentDetails(),
            if (widget.order.notes != null && widget.order.notes!.isNotEmpty) ...[
              SizedBox(height: 16),
              _buildNotesSection(),
            ],
            SizedBox(height: 16),
            _buildDeliveryDetails(),
            SizedBox(height: 24),
            _buildActionButtons(),
            SizedBox(height: 24,),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Order #${shortOrderId}...',
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
      color: Colors.white,
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
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Details',
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
      color: Colors.white,
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
              Text('Delivery information is not available yet. It may still be in processing.This might be due to incomplete shipping data.'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Card(
      color: Colors.white,
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
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Notes',
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
            icon: Icon(Icons.edit,color: Colors.white60,),
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
            onPressed: _showPrintDialog,
            icon: Icon(Icons.print,color: Colors.black,),
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