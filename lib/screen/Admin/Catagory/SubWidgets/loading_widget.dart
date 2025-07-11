import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getLoadingSizing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return {
        'containerSize': 50.0,
        'iconSize': 25.0,
        'textFontSize': 12.0,
        'progressWidth': 150.0,
        'spacing': 12.0,
      };
    } else if (screenWidth < 600) {
      return {
        'containerSize': 60.0,
        'iconSize': 30.0,
        'textFontSize': 14.0,
        'progressWidth': 200.0,
        'spacing': 16.0,
      };
    } else {
      return {
        'containerSize': 80.0,
        'iconSize': 40.0,
        'textFontSize': 16.0,
        'progressWidth': 250.0,
        'spacing': 24.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizing = _getLoadingSizing(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: RotationTransition(
              turns: _rotationAnimation,
              child: Container(
                width: sizing['containerSize'],
                height: sizing['containerSize'],
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue[400]!,
                      Colors.blue[600]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(sizing['containerSize'] / 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.category,
                  color: Colors.white,
                  size: sizing['iconSize'],
                ),
              ),
            ),
          ),
          SizedBox(height: sizing['spacing']),
          Text(
            widget.message ?? 'Loading categories...',
            style: TextStyle(
              fontSize: sizing['textFontSize'],
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: sizing['spacing'] * 0.75),
          SizedBox(
            width: sizing['progressWidth'],
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
          ),
        ],
      ),
    );
  }
}