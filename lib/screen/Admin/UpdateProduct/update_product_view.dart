import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/screen/Admin/AddProduct/AddProductCustom.dart';
import 'package:project/screen/Admin/AdminDrawer.dart';
import 'package:project/screen/model/ProductModel.dart';
import '../../TextSystem/enhanced_rich_text_editor.dart';
import 'update_product_controller.dart';

class UpdateProductPage extends StatefulWidget {
  final ProductModel product;
  final int selectedIndex;

  const UpdateProductPage({
    super.key, 
    required this.product,
    required this.selectedIndex,
  });

  @override
  _UpdateProductPageState createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  bool _isDarkMode = false;
  late UpdateProductController controller;

  @override
  void initState() {
    super.initState();
    controller = UpdateProductController(context: context);
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
                Text("Update Product")
              ],
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: AdminDrawer(isDarkMode: _isDarkMode, selectedNavIndex: widget.selectedIndex),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: UpdateProductFormCard(
          product: widget.product,
          controller: controller,
        ),
      ),
    );
  }
}

class UpdateProductFormCard extends StatefulWidget {
  final ProductModel product;
  final UpdateProductController controller;

  const UpdateProductFormCard({
    Key? key,
    required this.product,
    required this.controller,
  }) : super(key: key);

  @override
  _UpdateProductFormCardState createState() => _UpdateProductFormCardState();
}

class _UpdateProductFormCardState extends State<UpdateProductFormCard> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _newQuantityController = TextEditingController();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  bool _isDescriptionFocused = false;
  bool _showSearchBar = false;
  bool _allowCustomAmount = false;
  String _searchQuery = '';

  // Image handling
  var imageBytes;
  String imgUrl = "";
  final ImagePicker picker = ImagePicker();

  int _previousQuantity = 0;
  int _finalQuantity = 0;

  @override
  void initState() {
    super.initState();
    _initializeFormWithProductData();
    _initializeFocusListeners();
  }

  void _initializeFormWithProductData() async {
    // Pre-populate form fields with existing product data
    _titleController.text = widget.product.name;
    _descriptionController.text = widget.product.description;
    _priceController.text = widget.product.price.toString();
    _minPriceController.text = widget.product.minprice?.toString() ?? '';
    _maxPriceController.text = widget.product.maxprice?.toString() ?? '';
    _quantityController.text = widget.product.quantity.toString();
    
    _previousQuantity = widget.product.quantity;
    _finalQuantity = widget.product.quantity;
    
    // Set image
    imgUrl = widget.product.imgurl;
    if (imgUrl.isNotEmpty) {
      try {
        imageBytes = base64Decode(imgUrl);
      } catch (e) {
        print("Error decoding image: $e");
      }
    }

    // Get category name
    String categoryName = await widget.controller.getCategoryNameById(widget.product.categoryid ?? '');
    _categoryController.text = categoryName;

    // Set custom amount toggle
    _allowCustomAmount = widget.product.minprice != null && widget.product.maxprice != null;

    setState(() {});
  }

  void _initializeFocusListeners() {
    _descriptionFocusNode.addListener(() {
      setState(() {
        _isDescriptionFocused = _descriptionFocusNode.hasFocus;
      });
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    _newQuantityController.addListener(() {
      int newQty = int.tryParse(_newQuantityController.text) ?? 0;
      setState(() {
        _finalQuantity = _previousQuantity + newQty;
        _quantityController.text = _finalQuantity.toString();
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _priceController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _newQuantityController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List byteImage = await image.readAsBytes();
      final String base64img = base64Encode(byteImage);
      setState(() {
        imgUrl = base64img;
        imageBytes = base64Decode(imgUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name & Description Section
                SectionHeader(title: 'Name & description'),
                SizedBox(height: 24),

                // Product Title
                ProductTitleField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                ),
                SizedBox(height: 24),

                // Enhanced Description with Rich Text Editor
                EnhancedRichTextEditor(
                  controller: _descriptionController,
                  focusNode: _descriptionFocusNode,
                  searchController: _searchController,
                  searchFocusNode: _searchFocusNode,
                  isFocused: _isDescriptionFocused,
                  showSearchBar: _showSearchBar,
                  searchQuery: _searchQuery,
                  onToggleSearch: () {
                    setState(() {
                      _showSearchBar = !_showSearchBar;
                      if (!_showSearchBar) {
                        _searchController.clear();
                        _searchQuery = '';
                      }
                    });
                  },
                  onCloseSearch: () => setState(() {
                    _showSearchBar = false;
                    _searchController.clear();
                    _searchQuery = '';
                  }),
                ),

                SizedBox(height: 24),

                // Price Section
                PriceSection(
                  priceController: _priceController,
                  minPriceController: _minPriceController,
                  maxPriceController: _maxPriceController,
                  allowCustomAmount: _allowCustomAmount,
                  formKey: _formKey,
                  onToggleCustomAmount: (value) {
                    setState(() => _allowCustomAmount = value);
                  },
                ),

                SizedBox(height: 40),

                // New Quantity Section
                _buildNewQuantitySection(),

                SizedBox(height: 40),

                // Current Quantity Display
                _buildCurrentQuantitySection(),

                SizedBox(height: 40),

                // Category Section
                SectionHeader(title: 'Category'),
                SizedBox(height: 16),
                CategoryDropdown(controller: _categoryController),
                SizedBox(height: 32),

                // Product Files Section
                ProductFilesSection(
                  imageBytes: imageBytes,
                  imgUrl: imgUrl,
                  onImageTap: getImage,
                ),

                SizedBox(height: 30),

                // Update Button
                Center(
                  child: _buildUpdateButton(),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Add New Stock'),
        SizedBox(height: 16),
        TextFormField(
          controller: _newQuantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
          ],
          decoration: InputDecoration(
            labelText: 'New Product Quantity to Add',
            prefixIcon: Padding(
              padding: EdgeInsets.all(14.0),
              child: Icon(Icons.add_box, color: Colors.green),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Quantity Summary'),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Previous Quantity:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '$_previousQuantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Adding:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    '+${int.tryParse(_newQuantityController.text) ?? 0}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.blue[300]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Final Quantity:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    '$_finalQuantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          // Create updated product model
          ProductModel updatedProduct = ProductModel(
            id: widget.product.id,
            name: _titleController.text,
            price: double.tryParse(_priceController.text) ?? 0.0,
            description: _descriptionController.text,
            minprice: _allowCustomAmount ? double.tryParse(_minPriceController.text) : null,
            maxprice: _allowCustomAmount ? double.tryParse(_maxPriceController.text) : null,
            categoryid: _categoryController.text,
            quantity: _finalQuantity,
            imgurl: imgUrl,
            createdAt: widget.product.createdAt,
          );

          // Call controller to update product
          bool result = await widget.controller.updateProduct(updatedProduct, widget.product.id!);

          // Show result in SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result
                    ? 'Product updated successfully with rich formatting!'
                    : 'Failed to update product!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: result ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );

          if (result) {
            // Navigate back to previous screen
            Navigator.pop(context);
          }
        }
      },
      icon: Icon(Icons.update, color: Colors.white),
      label: Text(
        'Update Product',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
        shadowColor: Colors.blueAccent,
      ),
    );
  }
}