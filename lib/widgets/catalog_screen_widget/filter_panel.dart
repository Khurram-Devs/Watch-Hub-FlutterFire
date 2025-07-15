import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:watch_hub_ep/utils/string_utils.dart';
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
  final width = MediaQuery.of(context).size.width;

  return LayoutBuilder(
    builder: (context, constraints) {
      return Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Filters",
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

                Text("Brands", style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _brands.map((brand) {
                      final id = brand['id']!;
                      final name = brand['name']!;
                      final isSelected = _selectedBrand == id;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(capitalize(name)),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedBrand = isSelected ? null : id;
                            });
                          },
                          selectedColor: ThemeProvider.goldenAccent,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w500,
                          ),
                          backgroundColor: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                Text("Categories", style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
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
                          selectedColor: ThemeProvider.goldenAccent,
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
                                color: selected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : theme.colorScheme.secondary,
                                placeholderBuilder: (_) =>
                                    const SizedBox(width: 18, height: 18),
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported,
                                        size: 18),
                              ),
                              const SizedBox(width: 6),
                              Text(
                               capitalizeEachWord(name),
                                style: TextStyle(
                                  color: selected
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
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                Text("Price Range", style: theme.textTheme.bodyMedium),
                const SizedBox(height: 6),
                RangeSlider(
                  min: 0,
                  max: 10000,
                  divisions: 100,
                  values: RangeValues(_min, _max),
                  labels: RangeLabels('\$${_min.toInt()}',
                      '\$${_max.toInt()}'),
                  onChanged: (range) {
                    setState(() {
                      _min = range.start;
                      _max = range.end;
                    });
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Checkbox(
                      value: _inStock,
                      onChanged: (val) {
                        setState(() => _inStock = val ?? false);
                      },
                    ),
                    const Text("In Stock"),
                    const SizedBox(width: 16),
                    Checkbox(
                      value: _discountOnly,
                      onChanged: (val) {
                        setState(() => _discountOnly = val ?? false);
                      },
                    ),
                    const Text("Discounted"),
                  ],
                ),

                const SizedBox(height: 24),

                Text("Minimum Rating", style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [null, 1, 2, 3, 4, 5].map((r) {
                    final isSelected = _minRating == r?.toDouble();
                    return ChoiceChip(
                      label: Text(r == null ? "Any" : "$r★ & Up"),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _minRating = isSelected ? null : r?.toDouble();
                        });
                      },
                      selectedColor: ThemeProvider.goldenAccent,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _notify,
                    icon: const Icon(Icons.check),
                    label: const Text("Apply Filters"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.cardColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


}
