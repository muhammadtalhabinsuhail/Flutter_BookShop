import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../AddCatagory.dart';

// class AddCategoryDialog extends StatefulWidget {
//   const AddCategoryDialog({super.key});
//
//   @override
//   State<AddCategoryDialog> createState() => _AddCategoryDialogState();
// }
//
// class _AddCategoryDialogState extends State<AddCategoryDialog>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _categoryController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _categoryController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _addCategory() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       final categoryController = Provider.of<CategoryController>(context, listen: false);
//       final categoryName = _categoryController.text.trim();
//
//       final success = await categoryController.createCategory(categoryName);
//
//       if (success) {
//         Navigator.of(context).pop(true);
//       } else {
//         _showErrorSnackBar(categoryController.errorMessage ?? 'Failed to add category');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Something went wrong: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
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
//
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
//               decoration: BoxDecoration(
//                 color: Colors.blue[100],
//                 borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
//               ),
//               child: Icon(
//                 Icons.add_circle_outline,
//                 color: Colors.blue[600],
//                 size: isSmallScreen ? 20 : 24,
//               ),
//             ),
//             SizedBox(width: isSmallScreen ? 8 : 12),
//             Text(
//               'Add New Category',
//               style: TextStyle(
//                 fontSize: isSmallScreen ? 18 : 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//           ],
//         ),
//         content: SizedBox(
//           width: isSmallScreen ? double.maxFinite : 400,
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Category Name',
//                   style: TextStyle(
//                     fontSize: isSmallScreen ? 14 : 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[700],
//                   ),
//                 ),
//                 SizedBox(height: isSmallScreen ? 6 : 8),
//                 TextFormField(
//                   controller: _categoryController,
//                   autofocus: true,
//                   textCapitalization: TextCapitalization.words,
//                   decoration: InputDecoration(
//                     hintText: 'Enter category name',
//                     prefixIcon: Icon(
//                       Icons.category,
//                       color: Colors.blue[600],
//                       size: isSmallScreen ? 20 : 24,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
//                       borderSide: BorderSide(color: Colors.grey[300]!),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
//                       borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
//                     ),
//                     errorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
//                       borderSide: const BorderSide(color: Colors.red, width: 2),
//                     ),
//                     focusedErrorBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
//                       borderSide: const BorderSide(color: Colors.red, width: 2),
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: isSmallScreen ? 12 : 16,
//                       vertical: isSmallScreen ? 12 : 16,
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Please enter a category name';
//                     }
//                     if (value.trim().length < 2) {
//                       return 'Category name must be at least 2 characters';
//                     }
//                     if (value.trim().length > 50) {
//                       return 'Category name must be less than 50 characters';
//                     }
//                     return null;
//                   },
//                   onFieldSubmitted: (_) => _addCategory(),
//                 ),
//                 SizedBox(height: isSmallScreen ? 12 : 16),
//                 Container(
//                   padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
//                     border: Border.all(color: Colors.blue[200]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.info_outline,
//                         color: Colors.blue[600],
//                         size: isSmallScreen ? 16 : 18,
//                       ),
//                       SizedBox(width: isSmallScreen ? 6 : 8),
//                       Expanded(
//                         child: Text(
//                           'Category names must be unique and will be automatically formatted.',
//                           style: TextStyle(
//                             fontSize: isSmallScreen ? 11 : 12,
//                             color: Colors.blue[700],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: isSmallScreen ? 14 : 16,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: _isLoading ? null : _addCategory,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue[600],
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
//               ),
//               padding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 16 : 20,
//                 vertical: isSmallScreen ? 8 : 12,
//               ),
//             ),
//             child: _isLoading
//                 ? SizedBox(
//                     width: isSmallScreen ? 16 : 20,
//                     height: isSmallScreen ? 16 : 20,
//                     child: const CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   )
//                 : Text(
//                     'Add Category',
//                     style: TextStyle(
//                       fontSize: isSmallScreen ? 14 : 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _categoryController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _addCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final categoryController = Provider.of<CategoryController>(context, listen: false);
    bool success = await categoryController.createCategory(_categoryController.text);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      _showErrorSnackBar(categoryController.errorMessage ?? 'Failed to add category');
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: Colors.blue[600],
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Text(
              'Add New Category',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: isSmallScreen ? double.maxFinite : 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Name',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                TextFormField(
                  controller: _categoryController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Enter category name',
                    prefixIcon: Icon(
                      Icons.category,
                      color: Colors.blue[600],
                      size: isSmallScreen ? 20 : 24,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                      borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 12 : 16,
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
                  onFieldSubmitted: (_) => _addCategory(),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: isSmallScreen ? 16 : 18,
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Expanded(
                        child: Text(
                          'Category names must be unique and will be automatically formatted.',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: Colors.blue[700],
                          ),
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
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _addCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
                vertical: isSmallScreen ? 8 : 12,
              ),
            ),
            child: _isLoading
                ? SizedBox(
              width: isSmallScreen ? 16 : 20,
              height: isSmallScreen ? 16 : 20,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              'Add Category',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}