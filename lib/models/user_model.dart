import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String name, email, phone, avatar;
  UserModel(this.name, this.email, this.phone, this.avatar);
  static UserModel fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      UserModel(
        doc.data()?['fullName'] ?? '',
        doc.data()?['email'] ?? '',
        doc.data()?['phone'] ?? '',
        doc.data()?['avatarUrl'] ?? '',
      );
}
