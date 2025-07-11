import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/screen/customers/Wishlist/wishlist_controller.dart';
import 'package:project/screen/customers/Wishlist/wishlist_screen.dart';
import '../Home/add_to_cart_button.dart';


class WishlistItemCard extends StatefulWidget {
  final WishlistItemWithProduct item;
  final VoidCallback onRemove;
  final VoidCallback? onCartUpdated;
  final VoidCallback? onNotesUpdated;

  const WishlistItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
    this.onCartUpdated,
    this.onNotesUpdated,
  }) : super(key: key);

  @override
  State<WishlistItemCard> createState() => _WishlistItemCardState();
}

class _WishlistItemCardState extends State<WishlistItemCard> {
  final WishlistController _wishlistController = WishlistController();
  final TextEditingController _notesController = TextEditingController();
  bool _isEditingNotes = false;
  bool _isUpdatingNotes = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.item.wishlistItem.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    setState(() {
      _isUpdatingNotes = true;
    });

    bool success = await _wishlistController.updateWishlistNotes(
      widget.item.product.id!,
      _notesController.text,
    );

    setState(() {
      _isUpdatingNotes = false;
      _isEditingNotes = false;
    });

    if (success) {
      if (widget.onNotesUpdated != null) {
        widget.onNotesUpdated!();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📝 Notes updated'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _cancelEditNotes() {
    setState(() {
      _isEditingNotes = false;
      _notesController.text = widget.item.wishlistItem.notes ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
    final DateFormat timeFormat = DateFormat('hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date and Remove Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.wishlistItem.addedAt != null 
                        ? dateFormat.format(widget.item.wishlistItem.addedAt!)
                        : 'Unknown Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.item.wishlistItem.addedAt != null 
                        ? timeFormat.format(widget.item.wishlistItem.addedAt!)
                        : 'Unknown Time',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Heart Icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Remove Button
                  GestureDetector(
                    onTap: widget.onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Product Details Row
          Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.item.product.imgurl.isNotEmpty
                      ? Image.memory(
                          base64Decode(widget.item.product.imgurl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
              ),

              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${widget.item.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.item.product.quantity > 0 ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.item.product.quantity > 0
                              ? 'Available (${widget.item.product.quantity} left)'
                              : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.item.product.quantity > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Notes Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (!_isEditingNotes)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditingNotes = true;
                          });
                        },
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isEditingNotes)
                  Column(
                    children: [
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add your notes here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isUpdatingNotes ? null : _cancelEditNotes,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isUpdatingNotes ? null : _saveNotes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: _isUpdatingNotes
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Text(
                    widget.item.wishlistItem.notes?.isNotEmpty == true
                        ? widget.item.wishlistItem.notes!
                        : 'No notes added yet. Tap edit to add notes.',
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.item.wishlistItem.notes?.isNotEmpty == true
                          ? Colors.black87
                          : Colors.grey[500],
                      fontStyle: widget.item.wishlistItem.notes?.isNotEmpty == true
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Add to Cart Button
          if (widget.item.product.quantity > 0)
            SizedBox(
              width: double.infinity,
              child: AddToCartButton(
                product: widget.item.product,
                onCartUpdated: widget.onCartUpdated,
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Out of Stock',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade400,
          ],
        ),
      ),
      child: const Icon(
        Icons.shopping_bag,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}