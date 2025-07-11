import 'package:cloud_firestore/cloud_firestore.dart';

class SelectedAreaModel {
  final String? id;
  final String area;

  SelectedAreaModel({
    this.id,
    required this.area,
  });

  Map<String, dynamic> toMap() {
    return {
      'Area': area,
    };
  }

  factory SelectedAreaModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return SelectedAreaModel(
      id: documentId,
      area: map['Area'] ?? '',
    );
  }

  factory SelectedAreaModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SelectedAreaModel.fromMap(data, doc.id);
  }

  static List<SelectedAreaModel> fromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => SelectedAreaModel.fromSnapshot(doc))
        .toList();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SelectedAreaModel && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

}