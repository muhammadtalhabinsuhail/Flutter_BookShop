import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Screens/Models/CategoryModel.dart';
import 'AddCatagory.dart';
import 'SubWidgets/add_category_dialog.dart';
import 'SubWidgets/category_card.dart';
import 'SubWidgets/delete_confirmation_dialog.dart';
import 'SubWidgets/edit_category_dialog.dart';
import 'SubWidgets/empty_state_widget.dart';
import 'SubWidgets/loading_widget.dart';
import 'SubWidgets/search_bar_widget.dart';

// class CategoryManagementScreen extends StatefulWidget {
//   const CategoryManagementScreen({super.key});
//
//   @override
//   State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
// }
//
// class _CategoryManagementScreenState extends State<CategoryManagementScreen>
//     with TickerProviderStateMixin {
//   late CategoryController _categoryController;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   final TextEditingController _searchController = TextEditingController();
//   List<CategoryModel> _filteredCategories = [];
//   bool _isSearching = false;
//   Set<String> _selectedCategories = {};
//   bool _isSelectionMode = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _categoryController = Provider.of<CategoryController>(context, listen: false);
//
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//
//     _loadCategories();
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadCategories() async {
//     await _categoryController.fetchCategories();
//     _updateFilteredCategories();
//   }
//
//   void _updateFilteredCategories() {
//     setState(() {
//       if (_searchController.text.isEmpty) {
//         _filteredCategories = _categoryController.categories;
//       } else {
//         _filteredCategories = _categoryController.searchCategories(_searchController.text);
//       }
//     });
//   }
//
//   void _onSearchChanged(String query) {
//     setState(() {
//       _isSearching = query.isNotEmpty;
//     });
//     _updateFilteredCategories();
//   }
//
//   void _toggleSelectionMode() {
//     setState(() {
//       _isSelectionMode = !_isSelectionMode;
//       if (!_isSelectionMode) {
//         _selectedCategories.clear();
//       }
//     });
//   }
//
//   void _toggleCategorySelection(String categoryId) {
//     setState(() {
//       if (_selectedCategories.contains(categoryId)) {
//         _selectedCategories.remove(categoryId);
//       } else {
//         _selectedCategories.add(categoryId);
//       }
//     });
//   }
//
//   Future<void> _deleteSelectedCategories() async {
//     if (_selectedCategories.isEmpty) return;
//
//     bool? confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => DeleteConfirmationDialog(
//         title: 'Delete Categories',
//         message: 'Are you sure you want to delete ${_selectedCategories.length} selected categories?',
//       ),
//     );
//
//     if (confirmed == true) {
//       bool success = await _categoryController.deleteMultipleCategories(_selectedCategories.toList());
//       if (success) {
//         _showSnackBar('Categories deleted successfully', Colors.green);
//         setState(() {
//           _selectedCategories.clear();
//           _isSelectionMode = false;
//         });
//         _updateFilteredCategories();
//       } else {
//         _showSnackBar(_categoryController.errorMessage ?? 'Failed to delete categories', Colors.red);
//       }
//     }
//   }
//
//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 600;
//     final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
//
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: _buildAppBar(isSmallScreen),
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Consumer<CategoryController>(
//           builder: (context, controller, child) {
//             if (controller.isLoading && controller.categories.isEmpty) {
//               return const LoadingWidget();
//             }
//
//             return RefreshIndicator(
//               onRefresh: _loadCategories,
//               color: Colors.blue[600],
//               child: Column(
//                 children: [
//                   _buildSearchSection(isSmallScreen),
//                   if (controller.errorMessage != null)
//                     _buildErrorBanner(controller.errorMessage!),
//                   Expanded(
//                     child: _filteredCategories.isEmpty
//                         ? EmptyStateWidget(
//                             isSearching: _isSearching,
//                             onAddPressed: () => _showAddCategoryDialog(),
//                           )
//                         : _buildCategoriesList(isSmallScreen, isMediumScreen),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//       floatingActionButton: _isSelectionMode ? null : _buildFloatingActionButton(),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar(bool isSmallScreen) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.blue[600],
//       foregroundColor: Colors.white,
//       title: _isSelectionMode
//           ? Text('${_selectedCategories.length} selected')
//           : const Text(
//               'Category Management',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//       actions: [
//         if (_isSelectionMode) ...[
//           if (_selectedCategories.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: _deleteSelectedCategories,
//               tooltip: 'Delete Selected',
//             ),
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: _toggleSelectionMode,
//             tooltip: 'Cancel Selection',
//           ),
//         ] else ...[
//           if (_filteredCategories.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.checklist),
//               onPressed: _toggleSelectionMode,
//               tooltip: 'Select Multiple',
//             ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadCategories,
//             tooltip: 'Refresh',
//           ),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildSearchSection(bool isSmallScreen) {
//     return Container(
//       padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 0,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: SearchBarWidget(
//         controller: _searchController,
//         onChanged: _onSearchChanged,
//         hintText: 'Search categories...',
//       ),
//     );
//   }
//
//   Widget _buildErrorBanner(String errorMessage) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.red[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red[200]!),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: Colors.red[600]),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               errorMessage,
//               style: TextStyle(color: Colors.red[800]),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => _categoryController.clearError(),
//             color: Colors.red[600],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCategoriesList(bool isSmallScreen, bool isMediumScreen) {
//     int crossAxisCount;
//     if (isSmallScreen) {
//       crossAxisCount = 1;
//     } else if (isMediumScreen) {
//       crossAxisCount = 2;
//     } else {
//       crossAxisCount = 3;
//     }
//
//     return Padding(
//       padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: crossAxisCount,
//           childAspectRatio: isSmallScreen ? 3.5 : 3.0,
//           crossAxisSpacing: isSmallScreen ? 8 : 16,
//           mainAxisSpacing: isSmallScreen ? 8 : 16,
//         ),
//         itemCount: _filteredCategories.length,
//         itemBuilder: (context, index) {
//           final category = _filteredCategories[index];
//           final isSelected = _selectedCategories.contains(category.docId);
//
//           return CategoryCard(
//             category: category,
//             isSelectionMode: _isSelectionMode,
//             isSelected: isSelected,
//             onTap: _isSelectionMode
//                 ? () => _toggleCategorySelection(category.docId!)
//                 : null,
//             onEdit: () => _showEditCategoryDialog(category),
//             onDelete: () => _showDeleteCategoryDialog(category),
//             onLongPress: _isSelectionMode ? null : _toggleSelectionMode,
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildFloatingActionButton() {
//     return FloatingActionButton.extended(
//       onPressed: _showAddCategoryDialog,
//       backgroundColor: Colors.blue[600],
//       foregroundColor: Colors.white,
//       icon: const Icon(Icons.add),
//       label: const Text('Add Category'),
//     );
//   }
//
//   Future<void> _showAddCategoryDialog() async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => const AddCategoryDialog(),
//     );
//
//     if (result == true) {
//       _showSnackBar('Category added successfully', Colors.green);
//       _updateFilteredCategories();
//     }
//   }
//
//   Future<void> _showEditCategoryDialog(CategoryModel category) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => EditCategoryDialog(category: category),
//     );
//
//     if (result == true) {
//       _showSnackBar('Category updated successfully', Colors.green);
//       _updateFilteredCategories();
//     }
//   }
//
//   Future<void> _showDeleteCategoryDialog(CategoryModel category) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => DeleteConfirmationDialog(
//         title: 'Delete Category',
//         message: 'Are you sure you want to delete "${category.categoriesname}"?',
//       ),
//     );
//
//     if (result == true) {
//       bool success = await _categoryController.deleteCategory(category.docId!);
//       if (success) {
//         _showSnackBar('Category deleted successfully', Colors.green);
//         _updateFilteredCategories();
//       } else {
//         _showSnackBar(_categoryController.errorMessage ?? 'Failed to delete category', Colors.red);
//       }
//     }
//   }
// }





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
        _filteredCategories = _categoryController.categories;
      } else {
        _filteredCategories = _categoryController.searchCategories(_searchController.text);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(isSmallScreen),
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
                  _buildSearchSection(isSmallScreen),
                  if (controller.errorMessage != null)
                    _buildErrorBanner(controller.errorMessage!),
                  Expanded(
                    child: _filteredCategories.isEmpty
                        ? EmptyStateWidget(
                      isSearching: _isSearching,
                      onAddPressed: () => _showAddCategoryDialog(),
                    )
                        : _buildCategoriesList(isSmallScreen, isMediumScreen),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _isSelectionMode ? null : _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isSmallScreen) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      title: _isSelectionMode
          ? Text('${_selectedCategories.length} selected')
          : const Text(
        'Category Management',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        if (_isSelectionMode) ...[
          if (_selectedCategories.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedCategories,
              tooltip: 'Delete Selected',
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _toggleSelectionMode,
            tooltip: 'Cancel Selection',
          ),
        ] else ...[
          if (_filteredCategories.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select Multiple',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
            tooltip: 'Refresh',
          ),
        ],
      ],
    );
  }

  Widget _buildSearchSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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

  Widget _buildErrorBanner(String errorMessage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.red[800]),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _categoryController.clearError(),
            color: Colors.red[600],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(bool isSmallScreen, bool isMediumScreen) {
    int crossAxisCount;
    if (isSmallScreen) {
      crossAxisCount = 1;
    } else if (isMediumScreen) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: isSmallScreen ? 3.5 : 3.0,
          crossAxisSpacing: isSmallScreen ? 8 : 16,
          mainAxisSpacing: isSmallScreen ? 8 : 16,
        ),
        itemCount: _filteredCategories.length,
        itemBuilder: (context, index) {
          final category = _filteredCategories[index];
          final isSelected = _selectedCategories.contains(category.id);












          return CategoryCard(
            category: category,
            isSelectionMode: _isSelectionMode,
            isSelected: isSelected,
            onTap: _isSelectionMode
                ? () => _toggleCategorySelection(category.id!)
                : null,
            onEdit: () => _showEditCategoryDialog(category),
            onDelete: () => _showDeleteCategoryDialog(category),
            onLongPress: _isSelectionMode ? null : _toggleSelectionMode,
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showAddCategoryDialog,
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Add Category'),
    );
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