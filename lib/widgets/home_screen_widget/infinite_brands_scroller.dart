import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:watch_hub_ep/theme/theme_provider.dart';

class InfiniteBrandsScroller extends StatefulWidget {
  const InfiniteBrandsScroller({super.key});

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

  List<String> _brandImages = [];
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchBrandsFromFirestore();
  }

  Future<void> _fetchBrandsFromFirestore() async {
    final query = await FirebaseFirestore.instance
        .collection('categories')
        .where('type', isEqualTo: 1)
        .get();

    final urls = query.docs
        .map((doc) => doc['iconUrl'] as String)
        .where((url) => url.isNotEmpty)
        .toList();

    if (urls.isNotEmpty) {
      _brandImages = List.generate(
        urls.length * _repeatFactor,
        (i) => urls[i % urls.length],
      );

      setState(() {
        _isReady = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final middle = _scrollController.position.maxScrollExtent / 2;
          _scrollController.jumpTo(middle);
        }
        _ticker = createTicker(_tick)..start();
      });
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth < 425 ? 120.0 : 180.0;

    return SizedBox(
      height: avatarSize + 24,
      child: _isReady
          ? ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _brandImages.length,
              itemBuilder: (context, index) {
                final imageUrl = _brandImages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _spacing / 2),
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black : Colors.grey,
                              blurRadius: 6,
                              offset: const Offset(0, 6),
                            ),
                          ],
                    ),
                    child: CircleAvatar(
                      radius: avatarSize / 2,
                      backgroundColor: theme.cardColor,
                      backgroundImage: NetworkImage(imageUrl,),
                    ),
                  ),
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
