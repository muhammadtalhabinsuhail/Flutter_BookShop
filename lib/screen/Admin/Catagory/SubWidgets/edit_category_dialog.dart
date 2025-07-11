import 'package:flutter/material.dart';
import 'package:project/screen/model/CategoryModel.dart';
import 'package:provider/provider.dart';
import '../AddCatagory.dart';

class EditCategoryDialog extends StatefulWidget {
  final CategoryModel category;

  const EditCategoryDialog({
    super.key,
    required this.category,
  });

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _categoryController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.category.categoriesname);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final categoryController = Provider.of<CategoryController>(context, listen: false);
    bool success = await categoryController.updateCategory(
      widget.category.id!,
      _categoryController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      _showErrorSnackBar(categoryController.errorMessage ?? 'Failed to update category');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Map<String, dynamic> _getDialogSizing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return {
        'titleFontSize': 16.0,
        'labelFontSize': 12.0,
        'textFontSize': 13.0,
        'buttonFontSize': 12.0,
        'iconSize': 18.0,
        'borderRadius': 12.0,
        'padding': 8.0,
        'spacing': 6.0,
      };
    } else if (screenWidth < 600) {
      return {
        'titleFontSize': 18.0,
        'labelFontSize': 14.0,
        'textFontSize': 14.0,
        'buttonFontSize': 14.0,
        'iconSize': 20.0,
        'borderRadius': 16.0,
        'padding': 10.0,
        'spacing': 8.0,
      };
    } else {
      return {
        'titleFontSize': 20.0,
        'labelFontSize': 16.0,
        'textFontSize': 16.0,
        'buttonFontSize': 16.0,
        'iconSize': 24.0,
        'borderRadius': 20.0,
        'padding': 12.0,
        'spacing': 12.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sizing = _getDialogSizing(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizing['borderRadius']),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(sizing['padding']),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(sizing['padding']),
              ),
              child: Icon(
                Icons.edit,
                color: Colors.orange[600],
                size: sizing['iconSize'],
              ),
            ),
            SizedBox(width: sizing['spacing']),
            Expanded(
              child: Text(
                'Edit Category',
                style: TextStyle(
                  fontSize: sizing['titleFontSize'],
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: screenWidth < 600 ? double.maxFinite : 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Name',
                  style: TextStyle(
                    fontSize: sizing['labelFontSize'],
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: sizing['spacing'] * 0.75),
                TextFormField(
                  controller: _categoryController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: sizing['textFontSize']),
                  decoration: InputDecoration(
                    hintText: 'Enter category name',
                    hintStyle: TextStyle(fontSize: sizing['textFontSize'] - 1),
                    prefixIcon: Icon(
                      Icons.category,
                      color: Colors.orange[600],
                      size: sizing['iconSize'],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(sizing['borderRadius'] * 0.6),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(sizing['borderRadius'] * 0.6),
                      borderSide: BorderSide(color: Colors.orange[600]!, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(sizing['borderRadius'] * 0.6),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(sizing['borderRadius'] * 0.6),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: sizing['padding'] + 2,
                      vertical: sizing['padding'] + 2,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category name';
                    }
                    if (value.trim().length < 2) {
                      return 'Category name must be at least 2 characters';
                    }
                    if (value.trim().length > 50) {
                      return 'Category name must be less than 50 characters';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _updateCategory(),
                ),
                SizedBox(height: sizing['spacing']),
                Container(
                  padding: EdgeInsets.all(sizing['padding']),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(sizing['borderRadius'] * 0.5),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber[700],
                            size: sizing['iconSize'] - 2,
                          ),
                          SizedBox(width: sizing['spacing'] * 0.75),
                          Text(
                            'Category Information',
                            style: TextStyle(
                              fontSize: sizing['textFontSize'] - 2,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sizing['spacing'] * 0.5),
                      Text(
                        'Created: ${widget.category.getFormattedCreatedDate()}',
                        style: TextStyle(
                          fontSize: sizing['textFontSize'] - 4,
                          color: Colors.amber[700],
                        ),
                      ),
                      if (widget.category.createdAt != widget.category.updatedAt)
                        Text(
                          'Last Updated: ${widget.category.getFormattedUpdatedDate()}',
                          style: TextStyle(
                            fontSize: sizing['textFontSize'] - 4,
                            color: Colors.amber[700],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: sizing['buttonFontSize'],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _updateCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sizing['borderRadius'] * 0.5),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: sizing['padding'] + 4,
                vertical: sizing['padding'] * 0.75,
              ),
            ),
            child: _isLoading
                ? SizedBox(
              width: sizing['iconSize'] - 4,
              height: sizing['iconSize'] - 4,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'Update Category',
              style: TextStyle(
                fontSize: sizing['buttonFontSize'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}