import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/screen/Admin/AddProduct/AddProductController.dart';
import 'package:project/screen/Admin/AddProduct/AddProductCustom.dart';
import 'package:project/screen/Admin/AdminDrawer.dart';
import 'package:project/screen/customers/Home/home_view.dart';
import 'package:project/screen/model/ProductModel.dart';

import '../AdminDashboard/AdminDashboardView.dart';


class ProductFormPage extends StatefulWidget {
  late int selectedIndex;

   ProductFormPage({super.key, required this.selectedIndex});

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}




class _ProductFormPageState extends State<ProductFormPage> {


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



 late AddroductController controller ;

  @override
  void initState() {
    super.initState();
    controller = AddroductController(
      context: context,
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 100),
            child: Row(

              children: [
                // Image.asset("logo.png",height: 45,),
                // SizedBox(width: 10,),
                Text("Product Management")
              ],
            ),
          ),
        ),
        centerTitle: true,

      ),
      drawer: AdminDrawer(isDarkMode: _isDarkMode, selectedNavIndex: widget.selectedIndex),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: ProductFormCard(),
      ),
    );
  }








  Widget _buildSidebar(BuildContext context) {
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductFormPage(selectedIndex: widget.selectedIndex,)));
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
}

class ProductFormCard extends StatefulWidget {
  @override
  _ProductFormCardState createState() => _ProductFormCardState();
}

class _ProductFormCardState extends State<ProductFormCard> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  bool _isTitleFocused = false;
  bool _isDescriptionFocused = false;
  bool _isSearchFocused = false;
  bool _showSearchBar = false;
  bool _allowCustomAmount = false;
  String _searchQuery = '';

  // Formatting states
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  double _fontSize = 14.0;

  // Image handling
  var imageBytes;
  String imgUrl = "";
  final ImagePicker picker = ImagePicker();

  // Compatibility options
  final Map<String, bool> _compatibilityOptions = {
    'Sketch': true,
    'Figma': true,
    'Adobe XD': false,
    'Photoshop': false,
    'Cinema 4D': false,
    'WordPress': false,
    'HTML': false,
    'Keynote': false,
    'Maya': false,
    'Blender': false,
    'Procreate': false,
    'Illustrator': false,
    'Framer': false,
    'In Design': false,
    'After Effect': false,
  };

  @override
  void initState() {
    super.initState();
    _initializeFocusListeners();
  }

  void _initializeFocusListeners() {
    _titleFocusNode.addListener(() {
      setState(() {
        _isTitleFocused = _titleFocusNode.hasFocus;
      });
    });

    _descriptionFocusNode.addListener(() {
      setState(() {
        _isDescriptionFocused = _descriptionFocusNode.hasFocus;
      });
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
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

                // Description with Rich Text Editor
                RichTextEditor(
                  controller: _descriptionController,
                  focusNode: _descriptionFocusNode,
                  searchController: _searchController,
                  searchFocusNode: _searchFocusNode,
                  isFocused: _isDescriptionFocused,
                  showSearchBar: _showSearchBar,
                  searchQuery: _searchQuery,
                  isBold: _isBold,
                  isItalic: _isItalic,
                  isUnderline: _isUnderline,
                  fontSize: _fontSize,
                  onToggleSearch: () {
                    setState(() {
                      _showSearchBar = !_showSearchBar;
                      if (!_showSearchBar) {
                        _searchController.clear();
                        _searchQuery = '';
                      }
                    });
                  },
                  onToggleBold: () => setState(() => _isBold = !_isBold),
                  onToggleItalic: () => setState(() => _isItalic = !_isItalic),
                  onToggleUnderline: () => setState(() => _isUnderline = !_isUnderline),
                  onDecreaseFontSize: () => setState(() {
                    if (_fontSize > 10) _fontSize -= 2;
                  }),
                  onIncreaseFontSize: () => setState(() {
                    if (_fontSize < 24) _fontSize += 2;
                  }),
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

                QuantitySection(quantityController: _quantityController, formKey: _formKey),


                SizedBox(height: 40),
                // Category Section
                SectionHeader(title: 'Category'),
                SizedBox(height: 16),
                CategoryDropdown(controller: _categoryController),
                SizedBox(height: 32),

                // Compatibility Section
                CompatibilitySection(
                  compatibilityOptions: _compatibilityOptions,
                  onToggleOption: (option) {
                    setState(() {
                      _compatibilityOptions[option] = !_compatibilityOptions[option]!;
                    });
                  },
                ),

                SizedBox(height: 20),

                // Product Files Section
                ProductFilesSection(
                  imageBytes: imageBytes,
                  imgUrl: imgUrl,
                  onImageTap: getImage,
                ),

                SizedBox(height: 30),

                // Register Button
                Center(
                  child: RegisterButton(

                    onPressed: () async {

                      // Create product model
                      ProductModel prodModel = ProductModel(
                        name: _titleController.text,
                        price: double.tryParse(_priceController.text) ?? 0.0,
                        description: _descriptionController.text,
                        minprice: double.tryParse(_minPriceController.text),
                        maxprice: double.tryParse(_maxPriceController.text),
                        categoryid: _categoryController.text,
                        quantity:int.tryParse(_quantityController.text)??0,
                        imgurl: imgUrl,
                      );

                      // Call controller to add product
                      AddroductController controller = AddroductController(context: context);
                      bool result = await controller.AddProduct(prodModel);

                      // Show result in SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result
                                ? 'Product has been registered!...'
                                : 'Product has not been registered successfully!...',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: result ? Colors.green : Colors.red,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },

                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }




}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem(this.icon, this.activeIcon, this.label);
}