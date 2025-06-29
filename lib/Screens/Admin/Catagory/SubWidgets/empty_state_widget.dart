import 'package:flutter/material.dart';

// class EmptyStateWidget extends StatefulWidget {
//   final bool isSearching;
//   final VoidCallback? onAddPressed;
//
//   const EmptyStateWidget({
//     super.key,
//     this.isSearching = false,
//     this.onAddPressed,
//   });
//
//   @override
//   State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
// }
//
// class _EmptyStateWidgetState extends State<EmptyStateWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
//
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 600;
//
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     widget.isSearching ? Icons.search_off : Icons.category_outlined,
//                     size: isSmallScreen ? 64 : 80,
//                     color: Colors.blue[400],
//                   ),
//                 ),
//                 SizedBox(height: isSmallScreen ? 16 : 24),
//                 Text(
//                   widget.isSearching ? 'No Results Found' : 'No Categories Yet',
//                   style: TextStyle(
//                     fontSize: isSmallScreen ? 20 : 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: isSmallScreen ? 8 : 12),
//                 Text(
//                   widget.isSearching
//                       ? 'Try adjusting your search terms or filters'
//                       : 'Start by adding your first book category',
//                   style: TextStyle(
//                     fontSize: isSmallScreen ? 14 : 16,
//                     color: Colors.grey[600],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 if (!widget.isSearching && widget.onAddPressed != null) ...[
//                   SizedBox(height: isSmallScreen ? 24 : 32),
//                   ElevatedButton.icon(
//                     onPressed: widget.onAddPressed,
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add First Category'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue[600],
//                       foregroundColor: Colors.white,
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isSmallScreen ? 20 : 24,
//                         vertical: isSmallScreen ? 12 : 16,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isSearching ? Icons.search_off : Icons.category_outlined,
                    size: isSmallScreen ? 64 : 80,
                    color: Colors.blue[400],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Text(
                  widget.isSearching ? 'No Results Found' : 'No Categories Yet',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  widget.isSearching
                      ? 'Try adjusting your search terms or filters'
                      : 'Start by adding your first book category',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!widget.isSearching && widget.onAddPressed != null) ...[
                  SizedBox(height: isSmallScreen ? 24 : 32),
                  ElevatedButton.icon(
                    onPressed: widget.onAddPressed,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Category'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 20 : 24,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
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