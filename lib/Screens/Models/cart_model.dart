import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String? id;
  final String userId;
  final String productId;
  final int quantity;
  final bool isCheckedOut;
  final DateTime? addedItem;
  final double totalPrice;

  CartModel({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.isCheckedOut,
    this.addedItem,
    required this.totalPrice,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'ProductId': productId,
      'quantity': quantity,
      'isCheckedOut': isCheckedOut,
      'AddedItem': addedItem ?? FieldValue.serverTimestamp(),
      'TotalPrice': totalPrice,
    };
  }

  // Create from Map
  factory CartModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return CartModel(
      id: documentId,
      userId: map['UserId'] ?? '',
      productId: map['ProductId'] ?? '',
      quantity: map['quantity'] ?? 0,
      isCheckedOut: map['isCheckedOut'] ?? false,
      addedItem: map['AddedItem']?.toDate(),
      totalPrice: (map['TotalPrice'] ?? 0).toDouble(),
    );
  }

  // Create from DocumentSnapshot
  factory CartModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartModel.fromMap(data, doc.id);
  }

  // Create list from QuerySnapshot
  static List<CartModel> fromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => CartModel.fromSnapshot(doc))
        .toList();
  }

  // Copy with method
  CartModel copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    bool? isCheckedOut,
    DateTime? addedItem,
    double? totalPrice,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      isCheckedOut: isCheckedOut ?? this.isCheckedOut,
      addedItem: addedItem ?? this.addedItem,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}