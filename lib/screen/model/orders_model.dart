import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersModel {
  final String? id;
  final String orderId;
  final String userId;
  final String cartId;
  final String productId;
  final double totalAmount;
  final String paymentMethod;
  final String orderStatus;
  final DateTime orderDate;
  final String? notes;
  final String paymentStatus;
  final DateTime? deliveryDate;

  OrdersModel({
    this.id,
    required this.orderId,
    required this.userId,
    required this.cartId,
    required this.productId,
    required this.totalAmount,
    required this.paymentMethod,
    this.orderStatus = 'Pending',
    required this.orderDate,
    this.notes,
    this.paymentStatus = 'Pending',
    this.deliveryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'productId': productId,
      'cartId':cartId,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'orderStatus': orderStatus,
      'orderDate': orderDate,
      'notes': notes,
      'paymentStatus': paymentStatus,
      'deliveryDate': deliveryDate,
    };
  }

  factory OrdersModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return OrdersModel(
      id: documentId,
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      cartId: map['cartId'] ?? '',
      productId: map['productId'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'COD',
      orderStatus: map['orderStatus'] ?? 'Pending',
      orderDate: map['orderDate']?.toDate() ?? DateTime.now(),
      notes: map['notes'],
      paymentStatus: map['paymentStatus'] ?? 'Pending',
      deliveryDate: map['deliveryDate']?.toDate(),
    );
  }

  factory OrdersModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrdersModel.fromMap(data, doc.id);
  }

  static List<OrdersModel> fromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => OrdersModel.fromSnapshot(doc))
        .toList();
  }
}