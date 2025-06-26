import 'package:flutter/material.dart';

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
}

class TestimonialCarousel extends StatefulWidget {
  final List<Testimonial> testimonials;

  const TestimonialCarousel({super.key, required this.testimonials});

  @override
  State<TestimonialCarousel> createState() => _TestimonialCarouselState();
}


class _TestimonialCarouselState extends State<TestimonialCarousel> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.testimonials.length ~/ 2;
    _controller = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.85,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;
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
                onPageChanged: (index) =>
                    setState(() => _currentIndex = index),
                itemCount: widget.testimonials.length,
                itemBuilder: (context, index) {
                  final t = widget.testimonials[index];
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
              children: List.generate(widget.testimonials.length, (index) {
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
