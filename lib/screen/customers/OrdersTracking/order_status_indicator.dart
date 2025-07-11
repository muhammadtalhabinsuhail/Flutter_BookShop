import 'package:flutter/material.dart';

class OrderStatusIndicator extends StatefulWidget {
  final String status;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;

  const OrderStatusIndicator({
    Key? key,
    required this.status,
    this.isActive = false,
    this.isCompleted = false,
    this.onTap,
  }) : super(key: key);

  @override
  _OrderStatusIndicatorState createState() => _OrderStatusIndicatorState();
}

class _OrderStatusIndicatorState extends State<OrderStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(OrderStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  Color _getStatusColor() {
    switch (widget.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'order placed':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'out for delivery':
        return Colors.teal;
      case 'delivered':
        return Colors.green[700]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'order placed':
        return Icons.shopping_cart;
      case 'approved':
        return Icons.verified;
      case 'processing':
        return Icons.settings;
      case 'shipped':
        return Icons.local_shipping;
      case 'out for delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = _getStatusColor();
    IconData statusIcon = _getStatusIcon();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isActive ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: widget.isCompleted || widget.isActive
                    ? statusColor
                    : Colors.grey[300],
                shape: BoxShape.circle,
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: statusColor.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ]
                    : widget.isCompleted
                        ? [
                            BoxShadow(
                              color: statusColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : [],
              ),
              child: widget.isActive
                  ? Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Icon(
                        statusIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                  : Icon(
                      widget.isCompleted ? Icons.check : statusIcon,
                      color: widget.isCompleted || widget.isActive
                          ? Colors.white
                          : Colors.grey[600],
                      size: 24,
                    ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}