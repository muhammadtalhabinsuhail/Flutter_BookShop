import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String email;
  final String password;
  final String? profile;
  final String role;
  final String userName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.email,
    required this.password,
    this.profile,
    required this.role,
    required this.userName,
    this.createdAt,
    this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'Email': email,
      'Password': password,
      'Profile': profile,
      'Role': role,
      'UserName': userName,
      'CreatedAt': createdAt ?? FieldValue.serverTimestamp(),
      'UpdatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return UserModel(
      id: documentId,
      email: map['Email'] ?? '',
      password: map['Password'] ?? '',
      profile: map['Profile'],
      role: map['Role'] ?? 'Customer',
      userName: map['UserName'] ?? '',
      createdAt: map['CreatedAt']?.toDate(),
      updatedAt: map['UpdatedAt']?.toDate(),
    );
  }

  // Create from DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }

  // Create list from QuerySnapshot
  static List<UserModel> fromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => UserModel.fromSnapshot(doc))
        .toList();
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    String? email,
    String? password,
    String? profile,
    String? role,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      profile: profile ?? this.profile,
      role: role ?? this.role,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}