import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String firstName, lastName, fullName, email, phone, occupation, avatar;
  UserModel(
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.phone,
    this.occupation,
    this.avatar,
  );
  static UserModel fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      UserModel(
        doc.data()?['firstName'] ?? '',
        doc.data()?['lastName'] ?? '',
        doc.data()?['fullName'] ?? '',
        doc.data()?['email'] ?? '',
        doc.data()?['phone'] ?? '',
        doc.data()?['occupation'] ?? '',
        doc.data()?['avatarUrl'] ?? '',
      );
}
