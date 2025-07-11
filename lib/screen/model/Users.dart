// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class UsersModel {
//   final String? id;
//   final String userName;
//   final String email;
//   final String password;
//   final String role;
//   final String? profile;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   UsersModel({
//     this.id,
//     required this.userName,
//     required this.email,
//     required this.password,
//     this.role = "customer",
//     this.profile,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   // Convert model to Map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'UserName': userName,
//       'Email': email,
//       'Password': password,
//       'Role': role,
//       'Profile': profile ?? '',
//       'CreatedAt': createdAt ?? FieldValue.serverTimestamp(),
//       'UpdatedAt': updatedAt ?? FieldValue.serverTimestamp(),
//     };
//   }
//
//   // Create model from Firestore document
//   factory UsersModel.fromMap(Map<String, dynamic> map, String documentId) {
//     return UsersModel(
//       id: documentId,
//       userName: map['UserName'] ?? '',
//       email: map['Email'] ?? '',
//       password: map['Password'] ?? '',
//       role: map['Role'] ?? 'customer',
//       profile: map['Profile'],
//       createdAt: map['CreatedAt']?.toDate(),
//       updatedAt: map['UpdatedAt']?.toDate(),
//     );
//   }
//
//   // Copy with method for updates
//   UsersModel copyWith({
//     String? id,
//     String? userName,
//     String? email,
//     String? password,
//     String? role,
//     String? profile,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return UsersModel(
//       id: id ?? this.id,
//       userName: userName ?? this.userName,
//       email: email ?? this.email,
//       password: password ?? this.password,
//       role: role ?? this.role,
//       profile: profile ?? this.profile,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }
//
// class UsersRepository {
//   static final CollectionReference _usersCollection =
//   FirebaseFirestore.instance.collection('User');
//
//   // CREATE - Add new user
//   static Future<bool> createUser(UsersModel user, String uid) async {
//     try {
//       await _usersCollection.doc(uid).set(user.toMap());
//       return true;
//     } catch (e) {
//       print('Error creating user: $e');
//       return false;
//     }
//   }
//
//   // READ - Get user by ID
//   static Future<UsersModel?> getUserById(String uid) async {
//     try {
//       DocumentSnapshot doc = await _usersCollection.doc(uid).get();
//       if (doc.exists) {
//         return UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//       }
//       return null;
//     } catch (e) {
//       print('Error getting user: $e');
//       return null;
//     }
//   }
//
//   // READ - Get user by email
//   static Future<UsersModel?> getUserByEmail(String email) async {
//     try {
//       QuerySnapshot querySnapshot = await _usersCollection
//           .where('Email', isEqualTo: email)
//           .limit(1)
//           .get();
//
//       if (querySnapshot.docs.isNotEmpty) {
//         DocumentSnapshot doc = querySnapshot.docs.first;
//         return UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//       }
//       return null;
//     } catch (e) {
//       print('Error getting user by email: $e');
//       return null;
//     }
//   }
//
//   // READ - Get all users
//   static Future<List<UsersModel>> getAllUsers() async {
//     try {
//       QuerySnapshot querySnapshot = await _usersCollection.get();
//       return querySnapshot.docs
//           .map((doc) => UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
//           .toList();
//     } catch (e) {
//       print('Error getting all users: $e');
//       return [];
//     }
//   }
//
//   // READ - Get users by role
//   static Future<List<UsersModel>> getUsersByRole(String role) async {
//     try {
//       QuerySnapshot querySnapshot = await _usersCollection
//           .where('Role', isEqualTo: role)
//           .get();
//
//       return querySnapshot.docs
//           .map((doc) => UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
//           .toList();
//     } catch (e) {
//       print('Error getting users by role: $e');
//       return [];
//     }
//   }
//
//   // UPDATE - Update user
//   static Future<bool> updateUser(String uid, UsersModel user) async {
//     try {
//       Map<String, dynamic> updateData = user.toMap();
//       updateData['UpdatedAt'] = FieldValue.serverTimestamp();
//
//       await _usersCollection.doc(uid).update(updateData);
//       return true;
//     } catch (e) {
//       print('Error updating user: $e');
//       return false;
//     }
//   }
//
//   // UPDATE - Update specific fields
//   static Future<bool> updateUserFields(String uid, Map<String, dynamic> fields) async {
//     try {
//       fields['UpdatedAt'] = FieldValue.serverTimestamp();
//       await _usersCollection.doc(uid).update(fields);
//       return true;
//     } catch (e) {
//       print('Error updating user fields: $e');
//       return false;
//     }
//   }
//
//   // DELETE - Delete user
//   static Future<bool> deleteUser(String uid) async {
//     try {
//       await _usersCollection.doc(uid).delete();
//       return true;
//     } catch (e) {
//       print('Error deleting user: $e');
//       return false;
//     }
//   }
//
//   // UTILITY - Check if user exists
//   static Future<bool> userExists(String uid) async {
//     try {
//       DocumentSnapshot doc = await _usersCollection.doc(uid).get();
//       return doc.exists;
//     } catch (e) {
//       print('Error checking user existence: $e');
//       return false;
//     }
//   }
//
//   // UTILITY - Check if email exists
//   static Future<bool> emailExists(String email) async {
//     try {
//       QuerySnapshot querySnapshot = await _usersCollection
//           .where('Email', isEqualTo: email)
//           .limit(1)
//           .get();
//
//       return querySnapshot.docs.isNotEmpty;
//     } catch (e) {
//       print('Error checking email existence: $e');
//       return false;
//     }
//   }
//
//   // STREAM - Listen to user changes
//   static Stream<UsersModel?> getUserStream(String uid) {
//     return _usersCollection.doc(uid).snapshots().map((doc) {
//       if (doc.exists) {
//         return UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//       }
//       return null;
//     });
//   }
//
//   // STREAM - Listen to all users
//   static Stream<List<UsersModel>> getAllUsersStream() {
//     return _usersCollection.snapshots().map((snapshot) {
//       return snapshot.docs
//           .map((doc) => UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
//           .toList();
//     });
//   }
// }
//

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersModel {
  final String? id;
  final String userName;
  final String email;
  final String password;
  final String role;
  final String? profile;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UsersModel({
    this.id,
    required this.userName,
    required this.email,
    required this.password,
    this.role = "Customer",
    this.profile,
    this.createdAt,
    this.updatedAt,
  });

  // Convert model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'UserName': userName,
      'Email': email,
      'Password': password,
      'Role': role,
      'Profile': profile ?? '',
      'CreatedAt': createdAt ?? FieldValue.serverTimestamp(),
      'UpdatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Create model from Firestore document
  factory UsersModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UsersModel(
      id: documentId,
      userName: map['UserName'] ?? '',
      email: map['Email'] ?? '',
      password: map['Password'] ?? '',
      role: map['Role'] ?? 'Customer',
      profile: map['Profile'],
      createdAt: map['CreatedAt']?.toDate(),
      updatedAt: map['UpdatedAt']?.toDate(),
    );
  }

  // Copy with method for updates
  UsersModel copyWith({
    String? id,
    String? userName,
    String? email,
    String? password,
    String? role,
    String? profile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UsersModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      profile: profile ?? this.profile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UsersRepository {
  static final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('User');

  // CREATE - Add new user
  static Future<bool> createUser(UsersModel user, String uid) async {
    try {
      await _usersCollection.doc(uid).set(user.toMap());
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // READ - Get user by ID
  static Future<UsersModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // READ - Get user by email
  static Future<UsersModel?> getUserByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await _usersCollection
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        return UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // READ - Get all users
  static Future<List<UsersModel>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _usersCollection.get();
      return querySnapshot.docs
          .map((doc) => UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // READ - Get users by role
  static Future<List<UsersModel>> getUsersByRole(String role) async {
    try {
      QuerySnapshot querySnapshot = await _usersCollection
          .where('Role', isEqualTo: role)
          .get();

      return querySnapshot.docs
          .map((doc) => UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  // UPDATE - Update user
  static Future<bool> updateUser(String uid, UsersModel user) async {
    try {
      Map<String, dynamic> updateData = user.toMap();
      updateData['UpdatedAt'] = FieldValue.serverTimestamp();

      await _usersCollection.doc(uid).update(updateData);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // UPDATE - Update specific fields
  static Future<bool> updateUserFields(String uid, Map<String, dynamic> fields) async {
    try {
      fields['UpdatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(uid).update(fields);
      return true;
    } catch (e) {
      print('Error updating user fields: $e');
      return false;
    }
  }

  // DELETE - Delete user
  static Future<bool> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // UTILITY - Check if user exists
  static Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // UTILITY - Check if email exists
  static Future<bool> emailExists(String email) async {
    try {
      QuerySnapshot querySnapshot = await _usersCollection
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  // STREAM - Listen to user changes
  static Stream<UsersModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // STREAM - Listen to all users
  static Stream<List<UsersModel>> getAllUsersStream() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UsersModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}