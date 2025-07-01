import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/testimonial_model.dart';

class TestimonialCarousel extends StatefulWidget {
  const TestimonialCarousel({super.key});

  @override
  State<TestimonialCarousel> createState() => _TestimonialCarouselState();
}

class _TestimonialCarouselState extends State<TestimonialCarousel> {
  late final PageController _controller;
  int _currentIndex = 0;

  Future<List<Testimonial>> fetchTestimonials() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('testimonials')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Testimonial.fromFirestore(doc)).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<Testimonial>>(
      future: fetchTestimonials(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No testimonials found.');
        }

        final testimonials = snapshot.data!;
        final bool isWide = MediaQuery.of(context).size.width > 600;
        final double cardHeight = isWide ? 320 : 280;
        final double avatarRadius = isWide ? 48 : 40;
        final double fontSize = isWide ? 18 : 16;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Testimonials",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: cardHeight,
              child: PageView.builder(
                controller: _controller,
                itemCount: testimonials.length,
                onPageChanged: (index) =>
                    setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final t = testimonials[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: avatarRadius,
                            backgroundImage: NetworkImage(t.imageUrl),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '"${t.testimonial}"',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              fontSize: fontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                              fontSize: fontSize,
                            ),
                          ),
                          Text(
                            t.occupation,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(testimonials.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.secondary
                        : theme.disabledColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
