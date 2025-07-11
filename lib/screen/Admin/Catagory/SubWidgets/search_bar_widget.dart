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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.01).animate(
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

  Map<String, dynamic> _getSearchBarSizing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return {
        'fontSize': 12.0,
        'iconSize': 18.0,
        'borderRadius': 10.0,
        'contentPadding': EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      };
    } else if (screenWidth < 600) {
      return {
        'fontSize': 14.0,
        'iconSize': 20.0,
        'borderRadius': 12.0,
        'contentPadding': EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      };
    } else {
      return {
        'fontSize': 16.0,
        'iconSize': 24.0,
        'borderRadius': 16.0,
        'contentPadding': EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizing = _getSearchBarSizing(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(sizing['borderRadius']),
          boxShadow: [
            BoxShadow(
              color: _isFocused
                  ? Colors.blue.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.08),
              spreadRadius: _isFocused ? 1 : 0,
              blurRadius: _isFocused ? 6 : 3,
              offset: const Offset(0, 1),
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
                fontSize: sizing['fontSize'],
              ),
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.search,
                  color: _isFocused ? Colors.blue[600] : Colors.grey[500],
                  size: sizing['iconSize'],
                ),
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey[500],
                  size: sizing['iconSize'] - 2,
                ),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(sizing['borderRadius']),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(sizing['borderRadius']),
                borderSide: BorderSide(
                  color: Colors.blue[600]!,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: sizing['contentPadding'],
            ),
            style: TextStyle(
              fontSize: sizing['fontSize'],
              color: Colors.grey[800],
            ),
          ),
        ),
      ),
    );
  }
}