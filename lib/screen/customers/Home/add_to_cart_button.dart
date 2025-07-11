import 'package:flutter/material.dart';
import 'package:project/screen/model/ProductModel.dart';
import '../Cart/cart_controller.dart';



class AddToCartButton extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onCartUpdated;

  const AddToCartButton({
    Key? key,
    required this.product,
    this.onCartUpdated,
  }) : super(key: key);

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton>
    with SingleTickerProviderStateMixin {
  final CartController _cartController = CartController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

// Or with additional book details (recommended)
    bool success = await _cartController.addToCart(
      widget.product.id!,
      widget.product.price,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (widget.onCartUpdated != null) {
        widget.onCartUpdated!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} added to cart!'),
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add items to cart'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: (widget.product.quantity > 0 && !_isLoading)
                  ? _addToCart
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.product.quantity > 0 ? 'Add to Cart' : 'Out of Stock',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}