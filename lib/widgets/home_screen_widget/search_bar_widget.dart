import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_hub_ep/utils/string_utils.dart';
import '../../models/product_model.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.hintText = "Search watches...",
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with WidgetsBindingObserver {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<ProductModel> _suggestions = [];
  List<ProductModel> _cachedProducts = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .limit(50)
              .get();

      _cachedProducts = await Future.wait(
        snapshot.docs.map((doc) async {
          return await ProductModel.fromFirestoreWithBrand(doc.data(), doc.id);
        }),
      );
    } catch (e) {
      debugPrint('Search loadProducts error: $e');
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterSuggestions(query.trim());
    });
  }

  void _filterSuggestions(String query) {
    _removeOverlay();
    if (query.isEmpty) {
      setState(() => _suggestions.clear());
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered =
        _cachedProducts.where((product) {
          return product.title.toLowerCase().contains(lowerQuery) ||
              product.brandName.toLowerCase().contains(lowerQuery) ||
              product.price.toString().contains(lowerQuery);
        }).toList();

    setState(() => _suggestions = filtered);

    if (_suggestions.isNotEmpty) {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final theme = Theme.of(context);

    return OverlayEntry(
      builder:
          (context) => Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 4,
            width: size.width,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              color: theme.cardColor,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  itemBuilder: (_, i) {
                    final product = _suggestions[i];
                    return InkWell(
                      onTap: () {
                        widget.controller.text = product.title;
                        _removeOverlay();
                        context.push('/product/${product.id}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.images.first,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.watch,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    capitalizeEachWord(product.title),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${capitalize(product.brandName)} • \$${product.price.toStringAsFixed(0)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
    );
  }

  void _removeOverlay() {
    if (_overlayEntry?.mounted ?? false) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _removeOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextField(
          controller: widget.controller,
          onChanged: _onSearchChanged,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                widget.controller.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.controller.clear();
                        setState(() => _suggestions.clear());
                        _removeOverlay();
                      },
                    )
                    : null,
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
