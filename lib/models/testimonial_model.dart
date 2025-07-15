import 'package:cloud_firestore/cloud_firestore.dart';

class Testimonial {
  final String avatarUrl;
  final String testimonial;
  final String fullName;
  final String occupation;

  Testimonial({
    required this.avatarUrl,
    required this.testimonial,
    required this.fullName,
    required this.occupation,
  });

  factory Testimonial.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Testimonial(
      avatarUrl: data['avatarUrl'] ?? '',
      testimonial: data['testimonial'] ?? '',
      fullName: data['fullName'] ?? '',
      occupation: data['occupation'] ?? '',
    );
  }
}
