import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/theme_provider.dart';

class FilterPanel extends StatefulWidget {
  final void Function(
    String? brand,
    double? min,
    double? max,
    List<String> categories, {
    bool? inStock,
    bool? discountedOnly,
    double? minRating,
  })
  onFilter;

  const FilterPanel({super.key, required this.onFilter});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  String? _selectedBrand;
  double _min = 0, _max = 10000;
  double? _minRating;
  bool _inStock = false;
  bool _discountOnly = false;
  List<Map<String, String>> _brands = [];
  List<Map<String, String>> _categories = [];
  List<String> _selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('categories')
        .where('type', isEqualTo: 1)
        .get()
        .then((snap) {
          setState(() {
            _brands =
                snap.docs
                    .map(
                      (doc) => {'id': doc.id, 'name': doc['name'].toString()},
                    )
                    .toList();
          });
        });

    FirebaseFirestore.instance
        .collection('categories')
        .where('type', isEqualTo: 2)
        .get()
        .then((snap) {
          setState(() {
            _categories =
                snap.docs
                    .map(
                      (doc) => {
                        'id': doc.id,
                        'name': doc['name'].toString(),
                        'iconUrl': doc['iconUrl'].toString(),
                      },
                    )
                    .toList();
          });
        });
  }

  void _notify() {
    widget.onFilter(
      _selectedBrand,
      _min,
      _max,
      _selectedCategoryIds,
      inStock: _inStock,
      discountedOnly: _discountOnly,
      minRating: _minRating,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedBrand = null;
      _min = 0;
      _max = 10000;
      _minRating = null;
      _inStock = false;
      _discountOnly = false;
      _selectedCategoryIds.clear();
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Title + Clear All
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filter",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text("Clear All"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Brand Dropdown
            DropdownButtonFormField<String>(
              value: _selectedBrand,
              hint: Text("Select Brand", style: Theme.of(context).textTheme.bodySmall,),
              isExpanded: true,
              items:
                  _brands
                      .map(
                        (b) => DropdownMenuItem(
                          value: b['id'],
                          child: Text( b['name']!,
                          style: Theme.of(context).textTheme.bodySmall,),
                          
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() => _selectedBrand = value);
                _notify();
              },
              decoration: InputDecoration(
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Chips
            Text("Categories", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _categories.map((cat) {
                      final id = cat['id']!;
                      final name = cat['name']!;
                      final iconUrl = cat['iconUrl']!;
                      final selected = _selectedCategoryIds.contains(id);
                      final safeUrl = 'https://corsproxy.io/?$iconUrl';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          selected: selected,
                          backgroundColor: theme.cardColor,
                          selectedColor:
                              selected
                                  ? (isDark
                                      ? ThemeProvider.goldenColor.withOpacity(
                                        0.2,
                                      )
                                      : ThemeProvider.goldenColor.withOpacity(
                                        0.85,
                                      ))
                                  : theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.network(
                                safeUrl,
                                height: 18,
                                width: 18,
                                color:
                                    selected
                                        ? (isDark ? Colors.black : Colors.white)
                                        : theme.colorScheme.secondary,
                                placeholderBuilder:
                                    (_) =>
                                        const SizedBox(width: 18, height: 18),
                                errorBuilder:
                                    (_, __, ___) => const Icon(
                                      Icons.image_not_supported,
                                      size: 18,
                                    ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                name,
                                style: TextStyle(
                                  color:
                                      selected
                                          ? (isDark
                                              ? Colors.black
                                              : Colors.white)
                                          : theme.textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          onSelected: (bool value) {
                            setState(() {
                              if (value) {
                                _selectedCategoryIds.add(id);
                              } else {
                                _selectedCategoryIds.remove(id);
                              }
                            });
                            _notify();
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Price Range
            Text("Price Range", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            RangeSlider(
              min: 0,
              max: 10000,
              divisions: 100,
              values: RangeValues(_min, _max),
              labels: RangeLabels('\$${_min.toInt()}', '\$${_max.toInt()}'),
              onChanged: (range) {
                setState(() {
                  _min = range.start;
                  _max = range.end;
                });
              },
              onChangeEnd: (_) => _notify(),
            ),
            const SizedBox(height: 24),

            // Availability & Discount Checkboxes
            Row(
              children: [
                Checkbox(
                  value: _inStock,
                  onChanged: (val) {
                    setState(() => _inStock = val ?? false);
                    _notify();
                  },
                ),
                const Text("In Stock"),
                const SizedBox(width: 16),
                Checkbox(
                  value: _discountOnly,
                  onChanged: (val) {
                    setState(() => _discountOnly = val ?? false);
                    _notify();
                  },
                ),
                const Text("Discounted"),
              ],
            ),
            const SizedBox(height: 12),

            // Minimum Rating Dropdown
            DropdownButtonFormField<double>(
              value: _minRating,
              hint: const Text("Minimum Rating"),
              items:
                  [null, 1, 2, 3, 4, 5].map((r) {
                    return DropdownMenuItem<double>(
                      value: r?.toDouble(),
                      child: Text(
                        r == null ? "Any" : "$r★ and up",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
              onChanged: (val) {
                setState(() => _minRating = val);
                _notify();
              },
              decoration: InputDecoration(
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
