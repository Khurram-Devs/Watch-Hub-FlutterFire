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

  static const double _scrollSpeed = 15;
  static const double _itemSpacing = 24.0;

  late final List<String> _infiniteList;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _infiniteList = List.generate(
      widget.brandImageUrls.length * 60,
      (i) => widget.brandImageUrls[i % widget.brandImageUrls.length],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final middle = _scrollController.position.maxScrollExtent / 2;
        _scrollController.jumpTo(middle);
        _isReady = true;
      }

      _ticker = createTicker(_onTick)..start();
    });
  }

  void _onTick(Duration elapsed) {
    if (!_isReady || !_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final newOffset = offset + _scrollSpeed / 60;

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

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _infiniteList.length,
        itemBuilder: (context, index) {
          final url = _infiniteList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: _itemSpacing / 2),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: theme.cardColor,
              backgroundImage: NetworkImage(url),
            ),
          );
        },
      ),
    );
  }
}
