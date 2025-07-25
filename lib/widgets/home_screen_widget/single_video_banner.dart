import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class SingleVideoBanner extends StatelessWidget {
  const SingleVideoBanner({
    super.key,
    this.collectionPath = 'siteSettings',
    this.documentId = 'global',
    this.fieldName = 'bannerVideoUrl',
    this.fallbackAssetPath = 'assets/images/fallback_banner.png',
  });

  final String collectionPath;
  final String documentId;
  final String fieldName;
  final String fallbackAssetPath;

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(documentId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _BannerFallbackImage(assetPath: fallbackAssetPath);
        }

        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const _BannerLoading();
        }

        final data = snapshot.data!.data();

        final List<String> urls =
            (data?[fieldName] as List<dynamic>?)
                ?.whereType<String>()
                .where((e) => e.trim().isNotEmpty)
                .toList() ??
            const [];

        if (urls.isEmpty) {
          return _BannerFallbackImage(assetPath: fallbackAssetPath);
        }

        final random = Random();
        final String selectedUrl = urls[random.nextInt(urls.length)];

        return _VideoBanner(
          key: ValueKey(selectedUrl),
          videoUrl: selectedUrl,
          fallbackAssetPath: fallbackAssetPath,
        );
      },
    );
  }
}

class _BannerLoading extends StatelessWidget {
  const _BannerLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final double height =
        screenWidth < 600
            ? screenWidth * 9 / 16
            : screenWidth < 1024
            ? screenWidth * 7 / 16
            : screenWidth * 6 / 16;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _BannerFallbackImage extends StatelessWidget {
  const _BannerFallbackImage({required this.assetPath});

  final String assetPath;

  double _calculateHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 600
        ? screenWidth * 9 / 16
        : screenWidth < 1024
        ? screenWidth * 7 / 16
        : screenWidth * 6 / 16;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = _calculateHeight(context);

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
              Image.asset(assetPath, fit: BoxFit.cover),
              _GradientOverlay(),
              _OverlayContent(theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoBanner extends StatefulWidget {
  final String videoUrl;
  final String fallbackAssetPath;

  const _VideoBanner({
    super.key,
    required this.videoUrl,
    required this.fallbackAssetPath,
  });

  @override
  State<_VideoBanner> createState() => _VideoBannerState();
}

class _VideoBannerState extends State<_VideoBanner> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    try {
      final uri = Uri.tryParse(widget.videoUrl);
      if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
        setState(() => _hasError = true);
        return;
      }

      _timeoutTimer = Timer(const Duration(seconds: 5), () {
        if (!_isInitialized && mounted) {
          setState(() => _hasError = true);
          _controller?.dispose();
          _controller = null;
        }
      });

      _controller =
          VideoPlayerController.networkUrl(uri)
            ..setLooping(true)
            ..setVolume(0)
            ..initialize()
                .then((_) {
                  if (!mounted) return;
                  _timeoutTimer?.cancel();
                  setState(() {
                    _isInitialized = true;
                  });
                  _controller?.play();
                })
                .catchError((_) {
                  if (mounted) {
                    _timeoutTimer?.cancel();
                    setState(() => _hasError = true);
                  }
                });

      _controller?.addListener(() {
        if (_controller?.value.hasError ?? false) {
          _timeoutTimer?.cancel();
          setState(() => _hasError = true);
        }
      });
    } catch (_) {
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  double _calculateHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 600
        ? screenWidth * 9 / 16
        : screenWidth < 1024
        ? screenWidth * 7 / 16
        : screenWidth * 6 / 16;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = _calculateHeight(context);

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
              if (_hasError)
                Image.asset(widget.fallbackAssetPath, fit: BoxFit.cover)
              else if (_isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                )
              else
                const Center(child: CircularProgressIndicator()),

              _GradientOverlay(),
              _OverlayContent(theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _OverlayContent extends StatelessWidget {
  const _OverlayContent({required this.theme});
  final ThemeData theme;

  double _getHeadingFontSize(double width) {
    if (width < 400) return 22;
    if (width < 600) return 26;
    if (width < 900) return 32;
    return 38; // For desktop
  }

  double _getBodyFontSize(double width) {
    if (width < 400) return 12;
    if (width < 600) return 14;
    return 16; // Tablet & desktop
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Elevate Your Style",
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: _getHeadingFontSize(screenWidth),
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            "Discover timeless luxury with our exclusive watch collection.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontSize: _getBodyFontSize(screenWidth),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: ElevatedButton(
              onPressed: () => context.push('/catalog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                "Discover",
                style: TextStyle(
                  fontSize: screenWidth < 400 ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

