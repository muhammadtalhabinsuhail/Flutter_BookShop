import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutModel {
  final String? id;
  final String userId;
  final String productId;
  final double totalAmount;
  final String paymentMethod;
  final String orderStatus;
  final DateTime orderDate;
  final String? notes;
  final String paymentStatus;
  final String CartId;

  CheckoutModel({
    this.id,
    required this.userId,
    required this.productId,
    required this.CartId,
    required this.totalAmount,
    this.paymentMethod = 'COD',
    this.orderStatus = 'Pending',
    required this.orderDate,
    this.notes,
    this.paymentStatus = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'CartId':CartId,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'orderStatus': orderStatus,
      'orderDate': orderDate,
      'notes': notes,
      'paymentStatus': paymentStatus,

    };
  }

  factory CheckoutModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return CheckoutModel(
      id: documentId,
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      CartId:  map['CartId'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'COD',
      orderStatus: map['orderStatus'] ?? 'Pending',
      orderDate: map['orderDate']?.toDate() ?? DateTime.now(),
      notes: map['notes'],
      paymentStatus: map['paymentStatus'] ?? 'Pending',
    );
  }

  factory CheckoutModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CheckoutModel.fromMap(data, doc.id);
  }
}