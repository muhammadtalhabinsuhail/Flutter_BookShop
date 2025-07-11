import 'package:cloud_firestore/cloud_firestore.dart';

class StatusHistoryModel {
  final String? id;
  final String status;
  final DateTime timestamp;
  final String message;
  final String orderId;

  StatusHistoryModel({
    this.id,
    required this.status,
    required this.timestamp,
    required this.message,
    required this.orderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'timestamp': timestamp,
      'message': message,
      'orderId': orderId,
    };
  }

  factory StatusHistoryModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return StatusHistoryModel(
      id: documentId,
      status: map['status'] ?? '',
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
      message: map['message'] ?? '',
      orderId: map['orderId'] ?? '',
    );
  }

  factory StatusHistoryModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StatusHistoryModel.fromMap(data, doc.id);
  }

  static List<StatusHistoryModel> fromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => StatusHistoryModel.fromSnapshot(doc))
        .toList();
  }
}