import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/testimonial_model.dart';

class TestimonialService {
  final _ref = FirebaseFirestore.instance.collection('testimonials');

  Future<List<Testimonial>> getTestimonials() async {
    final snapshot = await _ref.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Testimonial.fromFirestore(doc)).toList();
  }
}
