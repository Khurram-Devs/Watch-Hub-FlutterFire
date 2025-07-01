import 'package:cloud_firestore/cloud_firestore.dart';

class Testimonial {
  final String imageUrl;
  final String testimonial;
  final String name;
  final String occupation;

  Testimonial({
    required this.imageUrl,
    required this.testimonial,
    required this.name,
    required this.occupation,
  });

  factory Testimonial.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Testimonial(
      imageUrl: data['imageUrl'] ?? '',
      testimonial: data['testimonial'] ?? '',
      name: data['name'] ?? '',
      occupation: data['occupation'] ?? '',
    );
  }
}
