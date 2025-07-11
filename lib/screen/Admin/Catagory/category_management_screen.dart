import 'package:flutter/material.dart';
import 'package:project/screen/Admin/AdminDrawer.dart';
import 'package:project/screen/model/CategoryModel.dart';
import 'package:provider/provider.dart';
import 'AddCatagory.dart';
import 'SubWidgets/add_category_dialog.dart';
import 'SubWidgets/category_card.dart';
import 'SubWidgets/delete_confirmation_dialog.dart';
import 'SubWidgets/edit_category_dialog.dart';
import 'SubWidgets/empty_state_widget.dart';
import 'SubWidgets/loading_widget.dart';
import 'SubWidgets/search_bar_widget.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with TickerProviderStateMixin {
  late CategoryController _categoryController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  List<CategoryModel> _filteredCategories = [];
  bool _isSearching = false;
  Set<String> _selectedCategories = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _categoryController = Provider.of<CategoryController>(context, listen: false);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadCategories();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    await _categoryController.fetchCategories();
    _updateFilteredCategories();
  }

  void _updateFilteredCategories() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredCategories = _categoryController.categories.cast<CategoryModel>();
      } else {
        _filteredCategories = _categoryController.searchCategories(_searchController.text).cast<CategoryModel>();
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    _updateFilteredCategories();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedCategories.clear();
      }
    });
  }

  void _toggleCategorySelection(String categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
      }
    });
  }

  Future<void> _deleteSelectedCategories() async {
    if (_selectedCategories.isEmpty) return;

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete Categories',
        message: 'Are you sure you want to delete ${_selectedCategories.length} selected categories?',
      ),
    );

    if (confirmed == true) {
      bool success = await _categoryController.deleteMultipleCategories(_selectedCategories.toList());
      if (success) {
        _showSnackBar('Categories deleted successfully', Colors.green);
        setState(() {
          _selectedCategories.clear();
          _isSelectionMode = false;
        });
        _updateFilteredCategories();
      } else {
        _showSnackBar(_categoryController.errorMessage ?? 'Failed to delete categories', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Comprehensive responsive values calculation
  Map<String, dynamic> _getResponsiveValues(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;

    // Define precise breakpoints
    bool isVerySmallPhone = screenWidth < 320;
    bool isSmallPhone = screenWidth >= 320 && screenWidth < 360;
    bool isPhone = screenWidth >= 360 && screenWidth < 600;
    bool isSmallTablet = screenWidth >= 600 && screenWidth < 768;
    bool isTablet = screenWidth >= 768 && screenWidth < 1024;
    bool isLargeTablet = screenWidth >= 1024 && screenWidth < 1200;
    bool isDesktop = screenWidth >= 1200;

    // Calculate optimal grid configuration
    int crossAxisCount;
    double childAspectRatio;

    if (isVerySmallPhone) {
      crossAxisCount = 1;
      childAspectRatio = 3.2; // Very tall for single column
    } else if (isSmallPhone) {
      crossAxisCount = orientation == Orientation.portrait ? 1 : 2;
      childAspectRatio = orientation == Orientation.portrait ? 3.0 : 2.8;
    } else if (isPhone) {
      crossAxisCount = orientation == Orientation.portrait ? 2 : 3;
      childAspectRatio = orientation == Orientation.portrait ? 2.6 : 2.4;
    } else if (isSmallTablet) {
      crossAxisCount = orientation == Orientation.portrait ? 2 : 3;
      childAspectRatio = orientation == Orientation.portrait ? 2.4 : 2.2;
    } else if (isTablet) {
      crossAxisCount = orientation == Orientation.portrait ? 3 : 4;
      childAspectRatio = orientation == Orientation.portrait ? 2.2 : 2.0;
    } else if (isLargeTablet) {
      crossAxisCount = orientation == Orientation.portrait ? 3 : 5;
      childAspectRatio = 2.0;
    } else {
      crossAxisCount = orientation == Orientation.portrait ? 4 : 6;
      childAspectRatio = 1.8;
    }

    return {
      'crossAxisCount': crossAxisCount,
      'childAspectRatio': childAspectRatio,
      'crossAxisSpacing': isPhone ? 8.0 : (isTablet ? 12.0 : 16.0),
      'mainAxisSpacing': isPhone ? 8.0 : (isTablet ? 12.0 : 16.0),
      'padding': isPhone ? 8.0 : (isTablet ? 12.0 : 16.0),
      'isVerySmallPhone': isVerySmallPhone,
      'isSmallPhone': isSmallPhone,
      'isPhone': isPhone,
      'isSmallTablet': isSmallTablet,
      'isTablet': isTablet,
      'isLargeTablet': isLargeTablet,
      'isDesktop': isDesktop,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
    };
  }

  @override
  Widget build(BuildContext context) {
    final responsive = _getResponsiveValues(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(responsive),
      drawer: AdminDrawer(isDarkMode: false, selectedNavIndex: 2),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<CategoryController>(
          builder: (context, controller, child) {
            if (controller.isLoading && controller.categories.isEmpty) {
              return const LoadingWidget();
            }

            return RefreshIndicator(
              onRefresh: _loadCategories,
              color: Colors.blue[600],
              child: Column(
                children: [
                  _buildSearchSection(responsive),
                  if (controller.errorMessage != null)
                    _buildErrorBanner(controller.errorMessage!, responsive),
                  Expanded(
                    child: _filteredCategories.isEmpty
                        ? EmptyStateWidget(
                      isSearching: _isSearching,
                      onAddPressed: () => _showAddCategoryDialog(),
                    )
                        : _buildCategoriesGrid(responsive),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _isSelectionMode ? null : _buildFloatingActionButton(responsive),
    );
  }

  PreferredSizeWidget _buildAppBar(Map<String, dynamic> responsive) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      title: _isSelectionMode
          ? Text(
        '${_selectedCategories.length} selected',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: responsive['isPhone'] ? 16.0 : 18.0,
        ),
      )
          : Text(
        'Category Management',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: responsive['isPhone'] ? 16.0 : 18.0,
        ),
      ),
      actions: [
        if (_isSelectionMode) ...[
          if (_selectedCategories.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete,
                size: responsive['isPhone'] ? 20.0 : 22.0,
              ),
              onPressed: _deleteSelectedCategories,
              tooltip: 'Delete Selected',
            ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: responsive['isPhone'] ? 20.0 : 22.0,
            ),
            onPressed: _toggleSelectionMode,
            tooltip: 'Cancel Selection',
          ),
        ] else ...[
          if (_filteredCategories.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.checklist,
                size: responsive['isPhone'] ? 20.0 : 22.0,
              ),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select Multiple',
            ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: responsive['isPhone'] ? 20.0 : 22.0,
            ),
            onPressed: _loadCategories,
            tooltip: 'Refresh',
          ),
        ],
      ],
    );
  }

  Widget _buildSearchSection(Map<String, dynamic> responsive) {
    return Container(
      padding: EdgeInsets.all(responsive['padding']),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SearchBarWidget(
        controller: _searchController,
        onChanged: _onSearchChanged,
        hintText: 'Search categories...',
      ),
    );
  }

  Widget _buildErrorBanner(String errorMessage, Map<String, dynamic> responsive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive['padding']),
      margin: EdgeInsets.all(responsive['padding']),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[600],
            size: responsive['isPhone'] ? 16.0 : 18.0,
          ),
          SizedBox(width: responsive['isPhone'] ? 6.0 : 8.0),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red[800],
                fontSize: responsive['isPhone'] ? 11.0 : 12.0,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: responsive['isPhone'] ? 16.0 : 18.0,
            ),
            onPressed: () => _categoryController.clearError(),
            color: Colors.red[600],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(Map<String, dynamic> responsive) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 100,
          childAspectRatio: 100,
          crossAxisSpacing: 100,
          mainAxisSpacing: 100,
        ),
        itemCount: _filteredCategories.length,
        itemBuilder: (context, index) {
          final category = _filteredCategories[index];
          final isSelected = _selectedCategories.contains(category.id);

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 50)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(15 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: CategoryCard(
                    category: category,
                    isSelectionMode: _isSelectionMode,
                    isSelected: isSelected,
                    onTap: _isSelectionMode
                        ? () => _toggleCategorySelection(category.id!)
                        : () {
                      print('Category tapped: ${category.categoriesname}');
                    },
                    onLongPress: _isSelectionMode ? null : _toggleSelectionMode,
                    onEdit: () => _showEditCategoryDialog(category),
                    onDelete: () => _showDeleteCategoryDialog(category),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(Map<String, dynamic> responsive) {
    if (responsive['isPhone']) {
      return FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      );
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );

    if (result == true) {
      _showSnackBar('Category added successfully', Colors.green);
      _updateFilteredCategories();
    }
  }

  Future<void> _showEditCategoryDialog(CategoryModel category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditCategoryDialog(category: category),
    );

    if (result == true) {
      _showSnackBar('Category updated successfully', Colors.green);
      _updateFilteredCategories();
    }
  }

  Future<void> _showDeleteCategoryDialog(CategoryModel category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete Category',
        message: 'Are you sure you want to delete "${category.categoriesname}"?',
      ),
    );

    if (result == true) {
      bool success = await _categoryController.deleteCategory(category.id!);
      if (success) {
        _showSnackBar('Category deleted successfully', Colors.green);
        _updateFilteredCategories();
      } else {
        _showSnackBar(_categoryController.errorMessage ?? 'Failed to delete category', Colors.red);
      }
    }
  }
}