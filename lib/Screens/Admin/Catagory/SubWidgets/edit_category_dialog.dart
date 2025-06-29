import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Screens/Models/CategoryModel.dart';
import '../AddCatagory.dart';


// class EditCategoryDialog extends StatefulWidget {
//   final CategoryModel category;
//
//   const EditCategoryDialog({
//     super.key,
//     required this.category,
//   });
//
//   @override
//   State<EditCategoryDialog> createState() => _EditCategoryDialogState();
// }
//
// class _EditCategoryDialogState extends State<EditCategoryDialog>
//     with SingleTickerProviderStateMixin {
//   late TextEditingController _categoryController;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _categoryController = TextEditingController(text: widget.category.categoriesname);
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
//   Future<void> _updateCategory() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     final categoryController = Provider.of<CategoryController>(context, listen: false);
//     bool success = await categoryController.updateCategory(
//       widget.category.docId!,
//       _categoryController.text,
//     );
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     if (success) {
//       Navigator.of(context).pop(true);
//     } else {
//       _showErrorSnackBar(categoryController.errorMessage ?? 'Failed to update category');
//     }
//   }
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
//                 color: Colors.orange[100],
//                 borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
//               ),
//               child: Icon(
//                 Icons.edit,
//                 color: Colors.orange[600],
//                 size: isSmallScreen ? 20 : 24,
//               ),
//             ),
//             SizedBox(width: isSmallScreen ? 8 : 12),
//             Expanded(
//               child: Text(
//                 'Edit Category',
//                 style: TextStyle(
//                   fontSize: isSmallScreen ? 18 : 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[800],
//                 ),
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
//                       color: Colors.orange[600],
//                       size: isSmallScreen ? 20 : 24,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
//                       borderSide: BorderSide(color: Colors.grey[300]!),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
//                       borderSide: BorderSide(color: Colors.orange[600]!, width: 2),
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
//                   onFieldSubmitted: (_) => _updateCategory(),
//                 ),
//                 SizedBox(height: isSmallScreen ? 12 : 16),
//                 Container(
//                   padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
//                   decoration: BoxDecoration(
//                     color: Colors.amber[50],
//                     borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
//                     border: Border.all(color: Colors.amber[200]!),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             color: Colors.amber[700],
//                             size: isSmallScreen ? 16 : 18,
//                           ),
//                           SizedBox(width: isSmallScreen ? 6 : 8),
//                           Text(
//                             'Category Information',
//                             style: TextStyle(
//                               fontSize: isSmallScreen ? 12 : 13,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.amber[700],
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: isSmallScreen ? 4 : 6),
//                       Text(
//                         'Created: ${widget.category.getFormattedCreatedDate()}',
//                         style: TextStyle(
//                           fontSize: isSmallScreen ? 10 : 11,
//                           color: Colors.amber[700],
//                         ),
//                       ),
//                       if (widget.category.createdAt != widget.category.updatedAt)
//                         Text(
//                           'Last Updated: ${widget.category.getFormattedUpdatedDate()}',
//                           style: TextStyle(
//                             fontSize: isSmallScreen ? 10 : 11,
//                             color: Colors.amber[700],
//                           ),
//                         ),
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
//             onPressed: _isLoading ? null : _updateCategory,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange[600],
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
//                     'Update Category',
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
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
              ),
              child: Icon(
                Icons.edit,
                color: Colors.orange[600],
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Text(
                'Edit Category',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
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
                      color: Colors.orange[600],
                      size: isSmallScreen ? 20 : 24,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                      borderSide: BorderSide(color: Colors.orange[600]!, width: 2),
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
                  onFieldSubmitted: (_) => _updateCategory(),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
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
                            size: isSmallScreen ? 16 : 18,
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Text(
                            'Category Information',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
                        'Created: ${widget.category.getFormattedCreatedDate()}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 11,
                          color: Colors.amber[700],
                        ),
                      ),
                      if (widget.category.createdAt != widget.category.updatedAt)
                        Text(
                          'Last Updated: ${widget.category.getFormattedUpdatedDate()}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 11,
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
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _updateCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
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
              'Update Category',
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