import 'package:cloud_firestore/cloud_firestore.dart';

// class CategoryModel {
//   late final String docId;
//   final String categoriesname;
//   DateTime createdAt;
//   DateTime updatedAt;
//
//   CategoryModel({
//     required this.docId,
//     required this.categoriesname,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) : createdAt = createdAt ?? DateTime.now(),
//         updatedAt = updatedAt ?? DateTime.now();
//
//   // Convert CategoryModel to Map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'categoriesname': categoriesname,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'updatedAt': Timestamp.fromDate(updatedAt),
//     };
//   }
//
//   // Create CategoryModel from Firestore document
//   factory CategoryModel.fromMap(Map<String, dynamic> map, String documentId) {
//     return CategoryModel(
//       docId: documentId,
//       categoriesname: map['categoriesname'] ?? '',
//       createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//     );
//   }
//
//   // Create CategoryModel from Firestore DocumentSnapshot
//   factory CategoryModel.fromSnapshot(DocumentSnapshot snapshot) {
//     Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
//     return CategoryModel.fromMap(data, snapshot.id);
//   }
//
//   // Copy method for updates
//   CategoryModel copyWith({
//     String? id,
//     String? categoriesname,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return CategoryModel(
//       docId: id ?? this.docId,
//       categoriesname: categoriesname ?? this.categoriesname,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? DateTime.now(),
//     );
//   }
//
//   // Validation method
//   bool isValid() {
//     return categoriesname.trim().isNotEmpty;
//   }
//
//   // Get formatted creation date
//   String getFormattedCreatedDate() {
//     return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
//   }
//
//   // Get formatted update date
//   String getFormattedUpdatedDate() {
//     return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
//   }
//
//   @override
//   String toString() {
//     return 'CategoryModel{id: $docId, categoriesname: $categoriesname, createdAt: $createdAt, updatedAt: $updatedAt}';
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is CategoryModel &&
//         other.docId == docId &&
//         other.categoriesname == categoriesname;
//   }
//
//   @override
//   int get hashCode {
//     return docId.hashCode ^ categoriesname.hashCode;
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String? id;
  String categoriesname;
  DateTime createdAt;
  DateTime updatedAt;

  CategoryModel({
    this.id,
    required this.categoriesname,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert CategoryModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'categoriesname': categoriesname,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create CategoryModel from Firestore document
  factory CategoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CategoryModel(
      id: documentId,
      categoriesname: map['categoriesname'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create CategoryModel from Firestore DocumentSnapshot
  factory CategoryModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return CategoryModel.fromMap(data, snapshot.id);
  }

  // Copy method for updates
  CategoryModel copyWith({
    String? id,
    String? categoriesname,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      categoriesname: categoriesname ?? this.categoriesname,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Validation method
  bool isValid() {
    return categoriesname.trim().isNotEmpty;
  }

  // Get formatted creation date
  String getFormattedCreatedDate() {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  // Get formatted update date
  String getFormattedUpdatedDate() {
    return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
  }

  @override
  String toString() {
    return 'CategoryModel{id: $id, categoriesname: $categoriesname, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id == id &&
        other.categoriesname == categoriesname;
  }

  @override
  int get hashCode {
    return id.hashCode ^ categoriesname.hashCode;
  }
}