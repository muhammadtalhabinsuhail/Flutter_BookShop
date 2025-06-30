import 'package:flutter/material.dart';
import '../../../../Screens/Models/CategoryModel.dart';

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
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 400;

    // Dynamic sizing based on screen dimensions
    final cardPadding = isVerySmallScreen ? 8.0 : (isSmallScreen ? 12.0 : 16.0);
    final iconSize = isVerySmallScreen ? 18.0 : (isSmallScreen ? 20.0 : 24.0);
    final titleFontSize = isVerySmallScreen ? 14.0 : (isSmallScreen ? 16.0 : 18.0);
    final subtitleFontSize = isVerySmallScreen ? 9.0 : (isSmallScreen ? 10.0 : 12.0);
    final iconPadding = isVerySmallScreen ? 6.0 : (isSmallScreen ? 8.0 : 10.0);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          constraints: BoxConstraints(
            minHeight: isVerySmallScreen ? 120 : (isSmallScreen ? 140 : 160),
            maxHeight: screenHeight * 0.25, // Prevent overflow by limiting height
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[400]!,
                Colors.blue[600]!,
              ],
            )
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.blue[50]!,
              ],
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? Colors.blue.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                spreadRadius: widget.isSelected ? 2 : 0,
                blurRadius: widget.isSelected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: widget.isSelected
                  ? Colors.blue[300]!
                  : Colors.grey[200]!,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                // Header Row
                Row(
                  children: [
                    if (widget.isSelectionMode)
                      Container(
                        margin: EdgeInsets.only(right: isVerySmallScreen ? 8 : 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isVerySmallScreen ? 20 : 24,
                          height: isVerySmallScreen ? 20 : 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isSelected
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(
                              color: widget.isSelected
                                  ? Colors.white
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: widget.isSelected
                              ? Icon(
                            Icons.check,
                            size: isVerySmallScreen ? 12 : 16,
                            color: Colors.blue[600],
                          )
                              : null,
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? Colors.white.withOpacity(0.2)
                            : Colors.blue[100],
                        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                      ),
                      child: Icon(
                        Icons.category,
                        color: widget.isSelected
                            ? Colors.white
                            : Colors.blue[600],
                        size: iconSize,
                      ),
                    ),
                    const Spacer(),
                    if (!widget.isSelectionMode)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: widget.isSelected
                              ? Colors.white
                              : Colors.grey[600],
                          size: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            widget.onEdit?.call();
                          } else if (value == 'delete') {
                            widget.onDelete?.call();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                SizedBox(height: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)),

                // Content Section - Using Flexible instead of Expanded
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category Name
                      Text(
                        widget.category.categoriesname,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: widget.isSelected
                              ? Colors.white
                              : Colors.grey[800],
                          height: 1.2, // Better line height
                        ),
                        maxLines: isVerySmallScreen ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: isVerySmallScreen ? 4 : 8),

                      // Date Information - Compact layout
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                                color: widget.isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.grey[500],
                              ),
                              SizedBox(width: isVerySmallScreen ? 3 : (isSmallScreen ? 4 : 6)),
                              Expanded(
                                child: Text(
                                  'Created: ${widget.category.getFormattedCreatedDate()}',
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: widget.isSelected
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.grey[500],
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (widget.category.createdAt != widget.category.updatedAt)
                            Padding(
                              padding: EdgeInsets.only(top: isVerySmallScreen ? 1 : 2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.update,
                                    size: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                                    color: widget.isSelected
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.grey[500],
                                  ),
                                  SizedBox(width: isVerySmallScreen ? 3 : (isSmallScreen ? 4 : 6)),
                                  Expanded(
                                    child: Text(
                                      'Updated: ${widget.category.getFormattedUpdatedDate()}',
                                      style: TextStyle(
                                        fontSize: subtitleFontSize,
                                        color: widget.isSelected
                                            ? Colors.white.withOpacity(0.8)
                                            : Colors.grey[500],
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
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