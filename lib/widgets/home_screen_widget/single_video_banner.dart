import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:watch_hub_ep/screens/user/catalog_screen.dart';

class SingleVideoBanner extends StatefulWidget {
  final String videoUrl;

  const SingleVideoBanner({
    super.key,
    required this.videoUrl,
  });

  @override
  State<SingleVideoBanner> createState() => _SingleVideoBannerState();
}

class _SingleVideoBannerState extends State<SingleVideoBanner> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _controller.play();
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final double height = screenWidth < 600
        ? screenWidth * 9 / 16
        : screenWidth < 1024
            ? screenWidth * 7 / 16
            : screenWidth * 6 / 16;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: theme.cardColor,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _isInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Elevate Your Style",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: theme.colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Discover timeless luxury with our exclusive watch collection.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/catalog');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        "Discover",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
