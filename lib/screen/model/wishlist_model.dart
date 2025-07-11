import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String? id;
  final String userId;
  final String productId;
  final DateTime? addedAt;
  final String? notes;
  final bool isFavorite;

  WishlistModel({
    this.id,
    required this.userId,
    required this.productId,
    this.addedAt,
    this.notes,
    required this.isFavorite,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'addedAt': addedAt ?? FieldValue.serverTimestamp(),
      'notes': notes,
      'isFavorite': isFavorite,
    };
  }

  // Create from Map
  factory WishlistModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return WishlistModel(
      id: documentId,
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      addedAt: map['addedAt']?.toDate(),
      notes: map['notes'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  // Create from DocumentSnapshot
  factory WishlistModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WishlistModel.fromMap(data, doc.id);
  }

  // Create list from QuerySnapshot
  static List<WishlistModel> fromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => WishlistModel.fromSnapshot(doc))
        .toList();
  }

  // Copy with method
  WishlistModel copyWith({
    String? id,
    String? userId,
    String? productId,
    DateTime? addedAt,
    String? notes,
    bool? isFavorite,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      addedAt: addedAt ?? this.addedAt,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}