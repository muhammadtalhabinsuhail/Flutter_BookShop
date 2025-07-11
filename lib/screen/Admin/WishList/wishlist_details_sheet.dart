// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'admin_wishlist_controller.dart';
//
// class WishlistDetailsSheet extends StatelessWidget {
//   final AdminWishlistItem item;
//   final VoidCallback onDelete;
//
//   const WishlistDetailsSheet({
//     Key? key,
//     required this.item,
//     required this.onDelete,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.85,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       child: Column(
//         children: [
//           // Handle
//           Container(
//             margin: const EdgeInsets.only(top: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.blue[50],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           Icons.favorite,
//                           color: Colors.blue[600],
//                           size: 24,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Wishlist Details',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey[800],
//                               ),
//                             ),
//                             Text(
//                               'Added ${_formatDate(item.wishlistItem.addedAt)}',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => Navigator.pop(context),
//                         icon: Icon(Icons.close, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 32),
//
//                   // Product Section
//                   _buildSectionHeader('Product Information', Icons.inventory_2),
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: Colors.grey[200]!),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               width: 80,
//                               height: 80,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 gradient: LinearGradient(
//                                   colors: [Colors.blue[400]!, Colors.blue[600]!],
//                                 ),
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Image.memory(
//                                   base64Decode(item.product.imgurl),
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Icon(
//                                       Icons.image_not_supported,
//                                       color: Colors.white,
//                                       size: 32,
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     item.product.name ?? 'Unknown Product',
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     '\$${(item.product.price ?? 0).toStringAsFixed(2)}',
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.blue[600],
//                                     ),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                     decoration: BoxDecoration(
//                                       color: (item.product.isAvailable ?? 0) > 0
//                                           ? Colors.green[100]
//                                           : Colors.red[100],
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Text(
//                                       (item.product.isAvailable ?? 0) > 0
//                                           ? 'Available (${item.product.isAvailable})'
//                                           : 'Out of Stock',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                         color: (item.product.isAvailable ?? 0) > 0
//                                             ? Colors.green[700]
//                                             : Colors.red[700],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         if (item.product.description != null && item.product.description!.isNotEmpty) ...[
//                           const SizedBox(height: 16),
//                           const Divider(),
//                           const SizedBox(height: 16),
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               'Description',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey[700],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             item.product.description!,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                               height: 1.5,
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 32),
//
//                   // User Section
//                   _buildSectionHeader('customer Information', Icons.person),
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: Colors.blue[200]!),
//                     ),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 30,
//                           backgroundColor: Colors.blue[600],
//                           child: Text(
//                             (item.user.userName?.isNotEmpty == true)
//                                 ? item.user.userName![0].toUpperCase()
//                                 : 'U',
//                             style: const TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 item.user.userName ?? 'Unknown User',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 item.user.email ?? 'No email',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               if (item.user.userName != null ) ...[
//
//    // && item.user.phone!.isNotEmpty
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'phone number here',
//                                   // item.user.phone!,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Notes Section
//                   if (item.wishlistItem.notes != null && item.wishlistItem.notes!.isNotEmpty) ...[
//                     const SizedBox(height: 32),
//                     _buildSectionHeader('customer Notes', Icons.note),
//                     const SizedBox(height: 16),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.orange[50],
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(color: Colors.orange[200]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.format_quote, color: Colors.orange[600], size: 20),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'customer\'s Note',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.orange[700],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             item.wishlistItem.notes!,
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey[700],
//                               height: 1.5,
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//
//                   const SizedBox(height: 40),
//
//                   // Action Buttons
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () {
//                             Navigator.pop(context);
//                             onDelete();
//                           },
//                           icon: const Icon(Icons.delete_outline),
//                           label: const Text('Remove from Wishlist'),
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Colors.red,
//                             side: const BorderSide(color: Colors.red),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () {
//                             // TODO: Navigate to product details or contact user
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Feature coming soon!'),
//                                 backgroundColor: Colors.blue,
//                               ),
//                             );
//                           },
//                           icon: const Icon(Icons.contact_mail),
//                           label: const Text('Contact customer'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue[600],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, IconData icon) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.blue[100],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: Colors.blue[600], size: 20),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[800],
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _formatDate(DateTime? date) {
//     if (date == null) return 'Unknown date';
//
//     final now = DateTime.now();
//     final difference = now.difference(date);
//
//     if (difference.inDays == 0) {
//       return 'Today';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} days ago';
//     } else {
//       return DateFormat('MMM dd, yyyy').format(date);
//     }
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'admin_wishlist_controller.dart';

class WishlistDetailsSheet extends StatelessWidget {
  final AdminWishlistItem item;
  final VoidCallback onDelete;

  const WishlistDetailsSheet({
    Key? key,
    required this.item,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wishlist Details',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Added ${_formatDate(item.wishlistItem.addedAt)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Product Section
                  _buildSectionHeader('Product Information', Icons.inventory_2),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(item.product.imgurl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white,
                                      size: 32,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name, // Using 'name' from your ProductModel
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item.product.quantity > 0
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.product.quantity > 0
                                          ? 'Available (${item.product.quantity})'
                                          : 'Out of Stock',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: item.product.quantity > 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (item.product.description.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.product.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],

                        // Price Range (if available)
                        if (item.product.minprice != null && item.product.maxprice != null) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Price Range: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '\$${item.product.minprice!.toStringAsFixed(2)} - \$${item.product.maxprice!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // User Section
                  _buildSectionHeader('customer Information', Icons.person),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[600],
                          backgroundImage: item.user.profile != null && item.user.profile!.isNotEmpty
                              ? MemoryImage(base64Decode(item.user.profile!))
                              : null,
                          child: item.user.profile == null || item.user.profile!.isEmpty
                              ? Text(
                            item.user.userName.isNotEmpty
                                ? item.user.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.user.userName, // Using 'userName' from your UsersModel
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.user.role == 'Admin'
                                      ? Colors.orange[100]
                                      : Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.user.role,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: item.user.role == 'Admin'
                                        ? Colors.orange[700]
                                        : Colors.green[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notes Section
                  if (item.wishlistItem.notes != null && item.wishlistItem.notes!.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildSectionHeader('customer Notes', Icons.note),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.format_quote, color: Colors.orange[600], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'customer\'s Note',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.wishlistItem.notes!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Action Buttons
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: () {
                  //           Navigator.pop(context);
                  //           onDelete();
                  //         },
                  //         icon: const Icon(Icons.delete_outline),
                  //         label: const Text('Remove from Wishlist'),
                  //         style: OutlinedButton.styleFrom(
                  //           foregroundColor: Colors.red,
                  //           side: const BorderSide(color: Colors.red),
                  //           padding: const EdgeInsets.symmetric(vertical: 16),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     const SizedBox(height: 16),
                  //     Expanded(
                  //       child: ElevatedButton.icon(
                  //         onPressed: () {
                  //           // TODO: Navigate to product details or contact user
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             SnackBar(
                  //               content: Text('Contacting ${item.user.userName}...'),
                  //               backgroundColor: Colors.blue,
                  //             ),
                  //           );
                  //         },
                  //         icon: const Icon(Icons.contact_mail),
                  //         label: const Text('Contact Customer'),
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.blue[600],
                  //           foregroundColor: Colors.white,
                  //           padding: const EdgeInsets.symmetric(vertical: 16),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 160,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: const Text('Remove', style: TextStyle(fontSize: 14)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Contacting ${item.user.userName}...'),
                                backgroundColor: Colors.teal[600],
                              ),
                            );
                          },
                          icon: const Icon(Icons.quick_contacts_mail_outlined, size: 20,color: Colors.deepOrange,),
                          label: const Text('Contact', style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                        ),
                      ),
                    ],
                  )






                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[600], size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}