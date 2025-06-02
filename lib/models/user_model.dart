import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String firstName; // Now required
  final String lastName;
  final String profileImage;
  final Timestamp? createdAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.firstName, // Required
    this.lastName = '',
    this.profileImage = '',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String, // Required, will throw if missing
      lastName: map['lastName'] as String? ?? '',
      profileImage: map['profileImage'] as String? ?? '',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}
