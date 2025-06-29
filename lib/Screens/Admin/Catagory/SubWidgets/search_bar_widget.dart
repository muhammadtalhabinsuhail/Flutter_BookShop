import 'package:flutter/material.dart';

// class SearchBarWidget extends StatefulWidget {
//   final TextEditingController controller;
//   final Function(String) onChanged;
//   final String hintText;
//
//   const SearchBarWidget({
//     super.key,
//     required this.controller,
//     required this.onChanged,
//     this.hintText = 'Search...',
//   });
//
//   @override
//   State<SearchBarWidget> createState() => _SearchBarWidgetState();
// }
//
// class _SearchBarWidgetState extends State<SearchBarWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   bool _isFocused = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   void _onFocusChange(bool hasFocus) {
//     setState(() {
//       _isFocused = hasFocus;
//     });
//     if (hasFocus) {
//       _animationController.forward();
//     } else {
//       _animationController.reverse();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 600;
//
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
//           boxShadow: [
//             BoxShadow(
//               color: _isFocused
//                   ? Colors.blue.withOpacity(0.2)
//                   : Colors.grey.withOpacity(0.1),
//               spreadRadius: _isFocused ? 2 : 0,
//               blurRadius: _isFocused ? 8 : 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Focus(
//           onFocusChange: _onFocusChange,
//           child: TextFormField(
//             controller: widget.controller,
//             onChanged: widget.onChanged,
//             decoration: InputDecoration(
//               hintText: widget.hintText,
//               hintStyle: TextStyle(
//                 color: Colors.grey[500],
//                 fontSize: isSmallScreen ? 14 : 16,
//               ),
//               prefixIcon: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 child: Icon(
//                   Icons.search,
//                   color: _isFocused ? Colors.blue[600] : Colors.grey[500],
//                   size: isSmallScreen ? 20 : 24,
//                 ),
//               ),
//               suffixIcon: widget.controller.text.isNotEmpty
//                   ? IconButton(
//                       icon: Icon(
//                         Icons.clear,
//                         color: Colors.grey[500],
//                         size: isSmallScreen ? 18 : 20,
//                       ),
//                       onPressed: () {
//                         widget.controller.clear();
//                         widget.onChanged('');
//                       },
//                     )
//                   : null,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
//                 borderSide: BorderSide.none,
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
//                 borderSide: BorderSide(
//                   color: Colors.blue[600]!,
//                   width: 2,
//                 ),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 12 : 16,
//                 vertical: isSmallScreen ? 12 : 16,
//               ),
//             ),
//             style: TextStyle(
//               fontSize: isSmallScreen ? 14 : 16,
//               color: Colors.grey[800],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search...',
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: _isFocused
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: _isFocused ? 2 : 0,
              blurRadius: _isFocused ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Focus(
          onFocusChange: _onFocusChange,
          child: TextFormField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: isSmallScreen ? 14 : 16,
              ),
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.search,
                  color: _isFocused ? Colors.blue[600] : Colors.grey[500],
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey[500],
                  size: isSmallScreen ? 18 : 20,
                ),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                borderSide: BorderSide(
                  color: Colors.blue[600]!,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 12 : 16,
              ),
            ),
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }
}