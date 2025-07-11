import 'package:flutter/material.dart';

class EmptyStateWidget extends StatefulWidget {
  final bool isSearching;
  final VoidCallback? onAddPressed;

  const EmptyStateWidget({
    super.key,
    this.isSearching = false,
    this.onAddPressed,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getEmptyStateSizing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return {
        'iconSize': 48.0,
        'titleFontSize': 18.0,
        'subtitleFontSize': 12.0,
        'buttonFontSize': 12.0,
        'padding': 16.0,
        'spacing': 12.0,
        'iconPadding': 16.0,
      };
    } else if (screenWidth < 600) {
      return {
        'iconSize': 64.0,
        'titleFontSize': 20.0,
        'subtitleFontSize': 14.0,
        'buttonFontSize': 14.0,
        'padding': 24.0,
        'spacing': 16.0,
        'iconPadding': 24.0,
      };
    } else {
      return {
        'iconSize': 80.0,
        'titleFontSize': 24.0,
        'subtitleFontSize': 16.0,
        'buttonFontSize': 16.0,
        'padding': 32.0,
        'spacing': 24.0,
        'iconPadding': 32.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizing = _getEmptyStateSizing(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(sizing['padding']),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(sizing['iconPadding']),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isSearching ? Icons.search_off : Icons.category_outlined,
                    size: sizing['iconSize'],
                    color: Colors.blue[400],
                  ),
                ),
                SizedBox(height: sizing['spacing']),
                Text(
                  widget.isSearching ? 'No Results Found' : 'No Categories Yet',
                  style: TextStyle(
                    fontSize: sizing['titleFontSize'],
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: sizing['spacing'] * 0.5),
                Text(
                  widget.isSearching
                      ? 'Try adjusting your search terms or filters'
                      : 'Start by adding your first book category',
                  style: TextStyle(
                    fontSize: sizing['subtitleFontSize'],
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!widget.isSearching && widget.onAddPressed != null) ...[
                  SizedBox(height: sizing['spacing'] * 1.5),
                  ElevatedButton.icon(
                    onPressed: widget.onAddPressed,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Category'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: sizing['padding'] * 0.8,
                        vertical: sizing['spacing'] * 0.75,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sizing['spacing'] * 0.75),
                      ),
                      textStyle: TextStyle(
                        fontSize: sizing['buttonFontSize'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}