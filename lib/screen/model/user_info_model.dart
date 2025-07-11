import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfoModel {
  final String? id;
  final String selectedAreaId;
  final String phone;
  final String deliveryAddress;
  final String userId;

  UserInfoModel({
    this.id,
    required this.selectedAreaId,
    required this.phone,
    required this.deliveryAddress,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'SelectedAreaid': selectedAreaId,
      'Phone': phone,
      'deliveryAddress': deliveryAddress,
      'userId': userId,
    };
  }

  factory UserInfoModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return UserInfoModel(
      id: documentId,
      selectedAreaId: map['SelectedAreaid'] ?? '',
      phone: map['Phone'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  factory UserInfoModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserInfoModel.fromMap(data, doc.id);
  }



}