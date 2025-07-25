import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:watch_hub_ep/utils/string_utils.dart';

class TestimonialCarousel extends StatefulWidget {
  const TestimonialCarousel({super.key});

  @override
  State<TestimonialCarousel> createState() => _TestimonialCarouselState();
}

class _TestimonialCarouselState extends State<TestimonialCarousel> {
  late final PageController _controller;
  int _currentIndex = 0;
  late Future<List<DocumentSnapshot>> _testimonialFuture;

  Future<List<DocumentSnapshot>> fetchTestimonials() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('testimonials')
              .where('status', isEqualTo: 1)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs;
    } catch (e) {
      debugPrint("Error fetching testimonials: $e");
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);
    _testimonialFuture = fetchTestimonials();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAddTestimonialDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance
        .collection('usersProfile')
        .doc(user.uid);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Add Testimonial"),
            content: TextFormField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your testimonial',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;

                  try {
                    await FirebaseFirestore.instance
                        .collection('testimonials')
                        .add({
                          'testimonial': text,
                          'createdAt': Timestamp.now(),
                          'status': 0,
                          'userRef': userRef,
                        });

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Thank you! Your testimonial is pending approval.",
                        ),
                      ),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to submit: ${e.toString()}"),
                      ),
                    );
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<List<DocumentSnapshot>>(
      future: _testimonialFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                "Be the first to leave a testimonial!",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          );
        }

        final testimonials = snapshot.data!;
        final isWide = MediaQuery.of(context).size.width > 600;
        final double cardHeight = isWide ? 320 : 280;
        final double avatarRadius = isWide ? 48 : 40;
        final double fontSize = isWide ? 18 : 16;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Testimonials",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                if (user != null)
                  TextButton.icon(
                    onPressed: _showAddTestimonialDialog,
                    icon: const Icon(Icons.add_comment),
                    label: const Text("Add Testimonial"),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.secondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: cardHeight,
              child: PageView.builder(
                controller: _controller,
                itemCount: testimonials.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  final t = testimonials[index].data() as Map<String, dynamic>;
                  final userRef = t['userRef'] as DocumentReference?;

                  if (userRef == null) {
                    return const Center(child: Text("Missing user reference"));
                  }

                  return FutureBuilder<DocumentSnapshot>(
                    future: userRef.get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final userData =
                          userSnap.data!.data() as Map<String, dynamic>? ?? {};
                      final fullName = capitalizeEachWord(
                        userData['fullName'] ?? 'Unnamed',
                      );
                      final avatarUrl = userData['avatarUrl'];
                      final occupation = capitalize(
                        userData['occupation'] ?? 'Customer',
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withValues(alpha: 0.1),
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
                                backgroundImage:
                                    avatarUrl != null
                                        ? NetworkImage(avatarUrl)
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '"${capitalize(t['testimonial'] ?? '')}"',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontSize: fontSize,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                fullName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                  fontSize: fontSize,
                                ),
                              ),
                              Text(
                                occupation,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                    color:
                        isActive
                            ? theme.colorScheme.secondary
                            : theme.disabledColor.withValues(alpha: 0.4),
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
