import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/screen/customers/Cart/cart_screen.dart';
import 'package:project/screen/customers/CheckOut/selected_area_controller.dart';
import 'package:project/screen/customers/base_customer_screen.dart';
import 'package:project/screen/model/ProductModel.dart';
import 'package:project/screen/model/cart_model.dart';
import 'package:project/screen/model/checkout_model.dart';
import 'package:project/screen/model/selected_area_model.dart';
import 'package:project/screen/model/user_info_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Cart/cart_controller.dart';
import '../Home/profile_avatar_widget.dart';
import 'checkout_controller.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> with TickerProviderStateMixin, WidgetsBindingObserver
{
  final _formKey = GlobalKey<FormState>();
  late var _phoneController = TextEditingController();
  late var _addressController = TextEditingController();
  final _notesController = TextEditingController();






  Future<void> getUserInfoByUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');

      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Get userId from User collection
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('User')
          .where('Email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
        return;
      }

      String userid = userQuery.docs.first.id;

      // Get user info from UserInfo collection
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('UserInfo')
          .where('userId', isEqualTo: userid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData = snapshot.docs.first.data() as Map<String, dynamic>;

        // ✅ Set values to controllers properly
        _phoneController.text = userData['Phone'];
        _addressController.text = userData['deliveryAddress'];


        print('Phone: ${_phoneController.text}, Address: ${_addressController.text}, Area: $_selectedArea');
      } else {
        print('No user info found for this userId.');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }



  final CartController _cartController = CartController();
  List<SelectedAreaModel> _areas = [];
  SelectedAreaModel? _selectedArea;
  String _paymentMethod = 'COD';
  List<CartModel> _cartItems = [];
  List<ProductModel> _products = [];
  double _totalAmount = 0.0;
  bool _isLoading = true;
  int _cartItemsCount = 0;

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;











  Future<void> ReversecheckoutCartItems() async {
    try {
      // Get current user email from preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');

      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Get user document by email
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('User')
          .where('Email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
        return;
      }





      String userId = userQuery.docs.first.id;

      // delete checkout items a/c to userid and orderplaced is false
      // delete checkout items a/c to userid and orderplaced is false
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Checkout')
          .where('userId', isEqualTo: userId)
          .where('orderStatus', isEqualTo: "Pending")
          .get();

      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }





      // Update all cart items for this user to isCheckedOut: true
      QuerySnapshot cartQuery = await FirebaseFirestore.instance
          .collection('Cart')
          .where('UserId', isEqualTo: userId)
          .where('isCheckedOut', isEqualTo: true)
          .where('OrderPlaced', isEqualTo: false)
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (QueryDocumentSnapshot doc in cartQuery.docs) {
        batch.update(doc.reference, {'isCheckedOut': false});
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must place order within 4 to 5 minutes after checking out!'),
          backgroundColor: Colors.black,
        ),
      );

      // Navigate to checkout page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartScreen()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  bool _orderPlaced = false;





  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
    getUserInfoByUserId();
    WidgetsBinding.instance.addObserver(this);

    // Optional: Set timer also
    Future.delayed(Duration(minutes: 5), () {
      if (!_orderPlaced) {
        ReversecheckoutCartItems(); // ⏳ In case user still on screen
      }
    });
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_orderPlaced) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
        // App minimized or closed
        ReversecheckoutCartItems(); // ✅ call here!
      }
    }
  }






















  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideAnimationController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleAnimationController, curve: Curves.elasticOut),
    );
  }

  Future<void> _loadData() async {
    await _loadAreas();
    await _loadCartItems();
    setState(() {
      _isLoading = false;
    });
    // Start animations after loading
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
    _scaleAnimationController.forward();
  }

  Future<void> _loadAreas() async {
    _areas = await SelectedAreaController.getAllAreas();
    setState(() {});
  }

  Future<void> _updateCartCount() async {
    try {
      int count = await _cartController.getCartCount();
      if (mounted) {
        setState(() {
          _cartItemsCount = count;
        });
      }
    } catch (e) {
      print('Error updating cart count: $e');
    }
  }

  Future<void> _loadCartItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');

      if (userEmail != null) {
        String? userId = await CheckoutController.getUserIdByEmail(userEmail);

        if (userId != null) {
          // Get cart items that are checked out
          QuerySnapshot cartQuery = await FirebaseFirestore.instance
              .collection('Cart')
              .where('UserId', isEqualTo: userId)
              .where('isCheckedOut', isEqualTo: true)
              .where('OrderPlaced',isEqualTo:false)
              .get();
          _cartItems = CartModel.fromQuerySnapshot(cartQuery);

          // Load product details and calculate total
          _totalAmount = 0.0;
          _products.clear();

          for (CartModel cart in _cartItems) {
            DocumentSnapshot productDoc = await FirebaseFirestore.instance
                .collection('Books')
                .doc(cart.productId)
                .get();

            if (productDoc.exists) {
              ProductModel product = ProductModel.fromSnapshot(productDoc);
              _products.add(product);
              _totalAmount += cart.totalPrice;
            }
          }
        }
      }
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }

  // Pakistani phone number validation
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }

    // Remove any spaces or special characters
    String cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');



    if (cleanNumber.length != 9) {
      return 'Phone number must be exactly 9 digits ';
    }

    return null;
  }

  // Address validation
  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter delivery address';
    }

    if (value.trim().length < 20) {
      return 'Please enter full address (minimum 20 characters)';
    }

    return null;
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate() || _selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');
      String? userId = await CheckoutController.getUserIdByEmail(userEmail!);
      if (userId != null) {
        // Create checkout entries
        List<CheckoutModel> checkoutItems = [];

        for (int i = 0; i < _cartItems.length; i++) {
          CheckoutModel checkout = CheckoutModel(
              id: _cartItems[i].id,
              userId: userId,
              productId: _cartItems[i].productId,
              totalAmount: _cartItems[i].totalPrice,
              paymentMethod: _paymentMethod,
              orderDate: DateTime.now(),
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              CartId: _cartItems[i].id.toString()
          );

          checkoutItems.add(checkout);
          await CheckoutController.addCheckout(checkout);
        }


        // Save user info
        UserInfoModel userInfo = UserInfoModel(
          selectedAreaId: _selectedArea!.id!,
          phone: _phoneController.text.trim(),
          deliveryAddress: _addressController.text.trim(),
          userId: userId,
        );

        QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('UserInfo')
            .where('userId', isEqualTo: userInfo.userId)
            .limit(1)
            .get();
        if (userQuery.docs.isEmpty) {
          // No existing doc → Add new
          await CheckoutController.addUserInfo(userInfo);
        } else {
          // Existing doc → Update it using its ID
          String docId = userQuery.docs.first.id;

          UserInfoModel updatedUserInfo = UserInfoModel(
            id: docId, // 💡 Set the Firestore document ID here
            selectedAreaId: _selectedArea!.id!,
            phone: _phoneController.text.trim(),
            deliveryAddress: _addressController.text.trim(),
            userId: userId,
          );

          await CheckoutController.updateUserInfo(updatedUserInfo);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout completed successfully!'),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Show place order dialog
        _showPlaceOrderDialog(checkoutItems);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showPlaceOrderDialog(List<CheckoutModel> checkoutItems) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                title: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Place Order',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[600]),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Do you want to place this order now?',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '\$${_totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _placeOrder(checkoutItems);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Place Order',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _placeOrder(List<CheckoutModel> checkoutItems) async {
    bool success = await CheckoutController.placeOrder(checkoutItems);

    if (success) {
      // Clear all form controllers
      _phoneController.clear();
      _addressController.clear();
      _notesController.clear();
      setState(() {
        _selectedArea = null;
        _paymentMethod = 'COD';
      });
      _orderPlaced = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Order placed successfully!'),
            ],
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pushReplacementNamed(context, '/my-orders');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Failed to place order'),
            ],
          ),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shopping',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Cart',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            ProfileAvatarWidget(
              onLoginRequired: () {
                // Handle login navigation
              },
              onLogoutSuccess: () {
                _updateCartCount();
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading checkout details...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  _buildOrderSummary(),
                  SizedBox(height: 24),

                  // Delivery Information
                  _buildDeliveryForm(),
                  SizedBox(height: 24),

                  // Payment Method
                  _buildPaymentMethod(),
                  SizedBox(height: 24),

                  // Notes
                  _buildNotesField(),
                  SizedBox(height: 32),

                  // Checkout Button
                  _buildCheckoutButton(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: EnhancedBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildOrderSummary() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _cartItems.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[200],
                  height: 24,
                ),
                itemBuilder: (context, index) {
                  if (index < _products.length) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 600 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(30 * (1 - value), 0),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child:
                                    Image(
                                      image: MemoryImage(base64Decode(_products[index].imgurl)),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.image, color: Colors.grey[500]),
                                      ),
                                    ),

                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _products[index].name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Qty: ${_cartItems[index].quantity}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '\$${_cartItems[index].totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14,
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
                  return SizedBox();
                },
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '\$${_totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryForm() {





    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.local_shipping_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Delivery Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Area Dropdown
                    DropdownButtonFormField<SelectedAreaModel>(
                      value: _selectedArea,
                      decoration: InputDecoration(
                        labelText: 'Select Area *',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                      ),
                      items: _areas.map((area) {
                        return DropdownMenuItem(
                          value: area,
                          child: Text(
                            area.area,
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedArea = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an area';
                        }
                        return null;
                      },
                      dropdownColor: Colors.white,
                    ),
                    SizedBox(height: 16),

                    // Phone Field with Pakistani validation
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number * (03XXXXXXXXX)',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        hintText: '03001234567',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[600]),
                        prefixText: '+92 ',
                        prefixStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: Colors.black),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: _validatePhoneNumber,
                    ),
                    SizedBox(height: 16),

                    // Address Field with character count validation
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Delivery Address * (minimum 20 characters)',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        hintText: 'Enter your complete delivery address with landmarks',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: Icon(Icons.home_outlined, color: Colors.grey[600]),
                        counterText: '${_addressController.text.length}/20 min',
                        counterStyle: TextStyle(
                          color: _addressController.text.length >= 20 ? Colors.green : Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      maxLines: 3,
                      style: TextStyle(color: Colors.black),
                      validator: _validateAddress,
                      onChanged: (value) {
                        setState(() {}); // Rebuild to update counter
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethod() {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.payment_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.money, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Cash on Delivery (COD)',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        value: 'COD',
                        groupValue: _paymentMethod,
                        activeColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesField() {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.note_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Additional Notes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Special instructions (optional)',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        hintText: 'e.g., Please contact before delivery',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: Icon(Icons.edit_note_outlined, color: Colors.grey[600]),
                      ),
                      maxLines: 3,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutButton() {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.grey[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _processCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_checkout_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }
}

















