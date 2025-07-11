import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTrackerModel {
  final String? id;
  final String orderId;
  final String userId;
  final String cartId;
  final String currentStatus;
  final String statusHistoryId;
  final DateTime? estimatedDelivery;
  final DateTime lastUpdated;

  OrderTrackerModel({
    this.id,
    required this.orderId,
    required this.userId,
    required this.cartId,
    required this.currentStatus,
    required this.statusHistoryId,
    this.estimatedDelivery,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'cartId': cartId,
      'currentStatus': currentStatus,
      'statusHistoryId': statusHistoryId,
      'estimatedDelivery': estimatedDelivery,
      'lastUpdated': lastUpdated,
    };
  }

  factory OrderTrackerModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return OrderTrackerModel(
      id: documentId,
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      cartId: map['cartId'] ?? '',
      currentStatus: map['currentStatus'] ?? '',
      statusHistoryId: map['statusHistoryId'] ?? '',
      estimatedDelivery: map['estimatedDelivery']?.toDate(),
      lastUpdated: map['lastUpdated']?.toDate() ?? DateTime.now(),
    );
  }

  factory OrderTrackerModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderTrackerModel.fromMap(data, doc.id);
  }
}