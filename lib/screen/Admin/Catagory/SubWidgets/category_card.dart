import 'package:flutter/material.dart';
import 'package:project/screen/model/CategoryModel.dart';

class CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onLongPress;

  const CategoryCard({
    super.key,
    required this.category,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onLongPress,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  // Get responsive sizing based on screen width
  // Map<String, dynamic> _getCardSizing(BuildContext context) {
    //   final screenWidth = MediaQuery.of(context).size.width;
    //
    //   bool isVerySmallPhone = screenWidth < 320;
    //   bool isSmallPhone = screenWidth >= 320 && screenWidth < 360;
    //   bool isPhone = screenWidth >= 360 && screenWidth < 600;
    //   bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    //   bool isDesktop = screenWidth >= 1024;
    //
    //   if (isVerySmallPhone) {
    //     return {
    //       'cardPadding': 6.0,
    //       'iconSize': 16.0,
    //       'iconPadding': 4.0,
    //       'titleFontSize': 12.0,
    //       'subtitleFontSize': 9.0,
    //       'menuIconSize': 14.0,
    //       'checkboxSize': 16.0,
    //       'borderRadius': 8.0,
    //       'spacing': 4.0,
    //     };
    //   } else if (isSmallPhone) {
    //     return {
    //       'cardPadding': 8.0,
    //       'iconSize': 18.0,
    //       'iconPadding': 5.0,
    //       'titleFontSize': 13.0,
    //       'subtitleFontSize': 10.0,
    //       'menuIconSize': 16.0,
    //       'checkboxSize': 18.0,
    //       'borderRadius': 10.0,
    //       'spacing': 5.0,
    //     };
    //   } else if (isPhone) {
    //     return {
    //       'cardPadding': 10.0,
    //       'iconSize': 20.0,
    //       'iconPadding': 6.0,
    //       'titleFontSize': 14.0,
    //       'subtitleFontSize': 11.0,
    //       'menuIconSize': 18.0,
    //       'checkboxSize': 20.0,
    //       'borderRadius': 12.0,
    //       'spacing': 6.0,
    //     };
    //   } else if (isTablet) {
    //     return {
    //       'cardPadding': 12.0,
    //       'iconSize': 22.0,
    //       'iconPadding': 7.0,
    //       'titleFontSize': 15.0,
    //       'subtitleFontSize': 12.0,
    //       'menuIconSize': 20.0,
    //       'checkboxSize': 22.0,
    //       'borderRadius': 14.0,
    //       'spacing': 7.0,
    //     };
    //   } else {
    //     return {
    //       'cardPadding': 14.0,
    //       'iconSize': 24.0,
    //       'iconPadding': 8.0,
    //       'titleFontSize': 16.0,
    //       'subtitleFontSize': 13.0,
    //       'menuIconSize': 22.0,
    //       'checkboxSize': 24.0,
    //       'borderRadius': 16.0,
    //       'spacing': 8.0,
    //     };
    //   }
    // }
  // }
  @override
  Widget build(BuildContext context) {
    // final sizing = _getCardSizing(context);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
            )
                : LinearGradient(
              colors: [Colors.white, Colors.blue[50]!],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? Colors.blue.withOpacity(0.25)
                    : Colors.grey.withOpacity(0.08),
                blurRadius: widget.isSelected ? 8 : 4,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: widget.isSelected ? Colors.blue[300]! : Colors.grey[200]!,
              width: widget.isSelected ? 1.5 : 0.8,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    if (widget.isSelectionMode)
                      Container(
                        margin: EdgeInsets.only(right:12),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isSelected ? Colors.white : Colors.transparent,
                            border: Border.all(
                              color: widget.isSelected ? Colors.white : Colors.grey[400]!,
                              width: 1.5,
                            ),
                          ),
                          child: widget.isSelected
                              ? Icon(
                            Icons.check,
                            size: 12 * 0.6,
                            color: Colors.blue[600],
                          )
                              : null,
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Colors.blue[100],
                        borderRadius: BorderRadius.circular(12 + 2),
                      ),
                      child: Icon(
                        Icons.category,
                        color: widget.isSelected ? Colors.white : Colors.blue[600],
                        size: 12,
                      ),
                    ),
                    Spacer(),
                    if (!widget.isSelectionMode)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 12,
                          color: widget.isSelected ? Colors.white : Colors.grey[600],
                        ),
                        onSelected: (value) {
                          if (value == 'edit') widget.onEdit?.call();
                          if (value == 'delete') widget.onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 14),
                                SizedBox(width: 6),
                                Text('Edit', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 14, color: Colors.red),
                                SizedBox(width: 6),
                                Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                SizedBox(height: 12),

                // Category name - Single line to prevent overflow
                Text(
                  widget.category.categoriesname,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.isSelected ? Colors.white : Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 12 * 0.8),

                // Dates section - Compact layout
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12 + 1,
                            color: widget.isSelected ? Colors.white70 : Colors.grey[500],
                          ),
                          SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              'Created: ${widget.category.getFormattedCreatedDate()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.isSelected ? Colors.white70 : Colors.grey[600],
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (widget.category.updatedAt != widget.category.createdAt) ...[
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.update,
                              size: 12 + 1,
                              color: widget.isSelected ? Colors.white70 : Colors.grey[500],
                            ),
                            SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                'Updated: ${widget.category.getFormattedUpdatedDate()}',
                                style: TextStyle(
                                  fontSize:12,
                                  color: widget.isSelected ? Colors.white70 : Colors.grey[600],
                                  height: 1.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}