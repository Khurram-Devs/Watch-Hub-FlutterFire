import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import 'package:watch_hub_ep/screens/admin/faq_screen.dart'; // Replace with ProductDetailScreen

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

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<ProductModel> _suggestions = [];

  Timer? _debounce;

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      await _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    _removeOverlay();

    if (query.isEmpty) {
      setState(() => _suggestions.clear());
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .limit(25)
        .get();

    final List<ProductModel> allProducts = await Future.wait(snapshot.docs.map((doc) async {
      return await ProductModel.fromFirestoreWithBrand(doc.data(), doc.id);
    }));

    final lowerQuery = query.toLowerCase();
    _suggestions = allProducts.where((product) {
      return product.title.toLowerCase().contains(lowerQuery) ||
          product.brandName.toLowerCase().contains(lowerQuery) ||
          product.price.toString().contains(lowerQuery);
    }).toList();

    setState(() {});

    if (_suggestions.isNotEmpty) {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    if (_overlayEntry?.mounted ?? false) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final imageSize = isWide ? 56.0 : 44.0;
    final fontSize = isWide ? 16.0 : 14.0;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + size.height + 4,
        width: size.width,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor),
              itemBuilder: (_, i) {
                final p = _suggestions[i];
                return InkWell(
                  onTap: () {
                    widget.controller.text = p.title;
                    _removeOverlay();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FAQScreen(), // Replace with: ProductDetailScreen(product: p)
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            p.images.first,
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: imageSize,
                              height: imageSize,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.watch),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${p.brandName} • \$${p.price.toStringAsFixed(0)}",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: fontSize - 1,
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75),
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

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: TextField(
          controller: widget.controller,
          onChanged: _onSearchChanged,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.controller.clear();
                      _removeOverlay();
                      setState(() => _suggestions.clear());
                    },
                  )
                : null,
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}
