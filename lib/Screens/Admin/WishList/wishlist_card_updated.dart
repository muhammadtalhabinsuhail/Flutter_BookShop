import 'dart:convert';
import 'package:flutter/material.dart';
import 'admin_wishlist_controller.dart';

class WishlistCard extends StatelessWidget {
  final AdminWishlistItem item;
  final int index;
  final VoidCallback onTap;

  const WishlistCard({
    Key? key,
    required this.item,
    required this.index,
    required this.onTap,
  }) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   return TweenAnimationBuilder<double>(
  //     duration: Duration(milliseconds: 600 + (index * 100)),
  //     tween: Tween(begin: 0.0, end: 1.0),
  //     builder: (context, value, child) {
  //       return Transform.scale(
  //         scale: value,
  //         child: GestureDetector(
  //           onTap: onTap,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(20),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.grey.withOpacity(0.1),
  //                   spreadRadius: 0,
  //                   blurRadius: 15,
  //                   offset: const Offset(0, 5),
  //                 ),
  //               ],
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Product Image
  //                 Expanded(
  //                   flex: 3,
  //                   child: Container(
  //                     width: double.infinity,
  //                     decoration: BoxDecoration(
  //                       borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  //                       gradient: LinearGradient(
  //                         begin: Alignment.topLeft,
  //                         end: Alignment.bottomRight,
  //                         colors: [
  //                           Colors.blue[400]!,
  //                           Colors.blue[600]!,
  //                         ],
  //                       ),
  //                     ),
  //                     child: Stack(
  //                       children: [
  //                         ClipRRect(
  //                           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  //                           child: Image.memory(
  //                             base64Decode(item.product.imgurl),
  //                             width: double.infinity,
  //                             height: double.infinity,
  //                             fit: BoxFit.cover,
  //                             errorBuilder: (context, error, stackTrace) {
  //                               return Center(
  //                                 child: Icon(
  //                                   Icons.image_not_supported,
  //                                   color: Colors.white,
  //                                   size: 40,
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //                         ),
  //
  //                         // Heart Icon
  //                         Positioned(
  //                           top: 12,
  //                           right: 12,
  //                           child: Container(
  //                             padding: const EdgeInsets.all(8),
  //                             decoration: BoxDecoration(
  //                               color: Colors.red,
  //                               shape: BoxShape.circle,
  //                               boxShadow: [
  //                                 BoxShadow(
  //                                   color: Colors.red.withOpacity(0.3),
  //                                   spreadRadius: 2,
  //                                   blurRadius: 8,
  //                                 ),
  //                               ],
  //                             ),
  //                             child: const Icon(
  //                               Icons.favorite,
  //                               color: Colors.white,
  //                               size: 16,
  //                             ),
  //                           ),
  //                         ),
  //
  //                         // Notes Indicator
  //                         if (item.wishlistItem.notes != null && item.wishlistItem.notes!.isNotEmpty)
  //                           Positioned(
  //                             top: 12,
  //                             left: 12,
  //                             child: Container(
  //                               padding: const EdgeInsets.all(6),
  //                               decoration: BoxDecoration(
  //                                 color: Colors.orange,
  //                                 borderRadius: BorderRadius.circular(8),
  //                               ),
  //                               child: const Icon(
  //                                 Icons.note,
  //                                 color: Colors.white,
  //                                 size: 14,
  //                               ),
  //                             ),
  //                           ),
  //
  //                         // Stock Status
  //                         Positioned(
  //                           bottom: 12,
  //                           left: 12,
  //                           child: Container(
  //                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                             decoration: BoxDecoration(
  //                               color: item.product.quantity > 0
  //                                   ? Colors.green.withOpacity(0.9)
  //                                   : Colors.red.withOpacity(0.9),
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                             child: Text(
  //                               item.product.quantity > 0
  //                                   ? 'In Stock (${item.product.quantity})'
  //                                   : 'Out of Stock',
  //                               style: const TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 10,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //
  //                 // Product Details
  //                 Expanded(
  //                   flex: 2,
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(12),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           item.product.name, // Using your ProductModel's 'name' field
  //                           style: const TextStyle(
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black87,
  //                           ),
  //                           maxLines: 2,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                         const SizedBox(height: 4),
  //                         Text(
  //                           '\$${item.product.price.toStringAsFixed(2)}',
  //                           style: TextStyle(
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.blue[600],
  //                           ),
  //                         ),
  //                         const Spacer(),
  //                         Row(
  //                           children: [
  //                             CircleAvatar(
  //                               radius: 12,
  //                               backgroundColor: Colors.blue[100],
  //                               backgroundImage: item.user.profile != null && item.user.profile!.isNotEmpty
  //                                   ? MemoryImage(base64Decode(item.user.profile!))
  //                                   : null,
  //                               child: item.user.profile == null || item.user.profile!.isEmpty
  //                                   ? Text(
  //                                       item.user.userName.isNotEmpty
  //                                           ? item.user.userName[0].toUpperCase()
  //                                           : 'U',
  //                                       style: TextStyle(
  //                                         fontSize: 12,
  //                                         fontWeight: FontWeight.bold,
  //                                         color: Colors.blue[600],
  //                                       ),
  //                                     )
  //                                   : null,
  //                             ),
  //                             const SizedBox(width: 8),
  //                             Expanded(
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Text(
  //                                     item.user.userName, // Using your UsersModel's 'userName' field
  //                                     style: TextStyle(
  //                                       fontSize: 12,
  //                                       fontWeight: FontWeight.w600,
  //                                       color: Colors.grey[700],
  //                                     ),
  //                                     overflow: TextOverflow.ellipsis,
  //                                   ),
  //                                   Text(
  //                                     item.user.role,
  //                                     style: TextStyle(
  //                                       fontSize: 10,
  //                                       color: item.user.role == 'Admin'
  //                                           ? Colors.orange[600]
  //                                           : Colors.green[600],
  //                                       fontWeight: FontWeight.w500,
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final cardHeight = screenHeight * 0.45; // Adjust height as needed

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Fixed height instead of Expanded
                      Container(
                        height: cardHeight * 0.55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[400]!,
                              Colors.blue[600]!,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Image.memory(
                                base64Decode(item.product.imgurl),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.image_not_supported, color: Colors.white, size: 40),
                                  );
                                },
                              ),
                            ),
                            // Heart
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.favorite, color: Colors.white, size: 16),
                              ),
                            ),
                            // Notes
                            if (item.wishlistItem.notes != null && item.wishlistItem.notes!.isNotEmpty)
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.note, color: Colors.white, size: 14),
                                ),
                              ),
                            // Stock
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: item.product.quantity > 0
                                      ? Colors.green.withOpacity(0.9)
                                      : Colors.red.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.product.quantity > 0
                                      ? 'In Stock (${item.product.quantity})'
                                      : 'Out of Stock',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ✅ Description section (remaining height)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.blue[100],
                                    backgroundImage: item.user.profile != null &&
                                        item.user.profile!.isNotEmpty
                                        ? MemoryImage(base64Decode(item.user.profile!))
                                        : null,
                                    child: item.user.profile == null || item.user.profile!.isEmpty
                                        ? Text(
                                      item.user.userName.isNotEmpty
                                          ? item.user.userName[0].toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[600],
                                      ),
                                    )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.user.userName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          item.user.role,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: item.user.role == 'Admin'
                                                ? Colors.orange[600]
                                                : Colors.green[600],
                                            fontWeight: FontWeight.w500,
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }











}