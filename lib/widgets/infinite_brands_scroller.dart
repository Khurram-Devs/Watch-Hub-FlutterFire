import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class InfiniteBrandsScroller extends StatefulWidget {
  final List<String> brandImageUrls;

  const InfiniteBrandsScroller({
    super.key,
    required this.brandImageUrls,
  });

  @override
  State<InfiniteBrandsScroller> createState() => _InfiniteBrandsScrollerState();
}

class _InfiniteBrandsScrollerState extends State<InfiniteBrandsScroller>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Ticker _ticker;

  static const double _scrollSpeed = 20.0;
  static const Duration _frameRate = Duration(milliseconds: 16);
  static const double _spacing = 16.0;
  static const int _repeatFactor = 60;

  late final List<String> _duplicatedImages;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _duplicatedImages = List.generate(
      widget.brandImageUrls.length * _repeatFactor,
      (i) => widget.brandImageUrls[i % widget.brandImageUrls.length],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final middle = _scrollController.position.maxScrollExtent / 2;
        _scrollController.jumpTo(middle);
        _isReady = true;
      }
      _ticker = createTicker(_tick)..start();
    });
  }

  void _tick(Duration elapsed) {
    if (!_isReady || !_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final newOffset = offset + _scrollSpeed * (_frameRate.inMilliseconds / 1000);

    if (newOffset >= maxExtent - 200) {
      final middle = maxExtent / 2;
      _scrollController.jumpTo(middle);
    } else {
      _scrollController.jumpTo(newOffset);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final avatarSize = screenWidth < 425 ? 120.0 : 180.0;

        return SizedBox(
          height: avatarSize + 24,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _duplicatedImages.length,
            itemBuilder: (context, index) {
              final imageUrl = _duplicatedImages[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: _spacing / 2),
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black
                            : Colors.grey,
                        blurRadius: 6,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: avatarSize / 2,
                    backgroundColor: theme.cardColor,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
