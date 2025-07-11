import 'package:flutter/material.dart';

class ImageGallery extends StatefulWidget {
  final List<String> images;

  const ImageGallery({super.key, required this.images});

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late final PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.images.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    double height;
    if (screenWidth < 500) {
      height = 280;
    } else if (screenWidth < 800) {
      height = 400;
    } else {
      height = 500;
    }

    return Column(
      children: [
        SizedBox(
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 12,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 32),
                  onPressed: _goToPrevious,
                  color: theme.colorScheme.secondary,
                ),
              ),
              Positioned(
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, size: 32),
                  onPressed: _goToNext,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) {
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
  }
}
