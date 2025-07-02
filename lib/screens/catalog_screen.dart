import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:watch_hub_ep/widgets/home_screen_widget/search_bar_widget.dart';
import '../../services/product_service.dart';
import '../../models/product_model.dart';
import '../../models/sort_option.dart';
import '../../widgets/catalog_screen_widget/filter_panel.dart';
import '../../widgets/catalog_screen_widget/sort_panel.dart';
import '../../widgets/catalog_screen_widget/view_toggle.dart';
import '../../widgets/catalog_screen_widget/product_grid_item.dart';
import '../../widgets/catalog_screen_widget/product_list_item.dart';
import '../../widgets/layout_widget/app_header.dart';
import '../../widgets/layout_widget/nav_drawer.dart';
import '../../widgets/layout_widget/footer_widget.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _service = ProductService();
  final TextEditingController _searchController = TextEditingController();
  String? _brand;
  double? _minPrice, _maxPrice;
  SortOption _sortBy = SortOption.New;
  bool _isGrid = true;
  List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    _fetchPage();
  }

Future<void> _fetchPage() async {
  if (_isLoading || !_hasMore) return;
  setState(() => _isLoading = true);

  final results = await _service.fetchCatalog(
    page: 1,
    limit: 20,
    sort: _sortBy,
    brand: _brand,
    minPrice: _minPrice,
    maxPrice: _maxPrice,
    lastDoc: _lastDoc,
    categories: _selectedCategories,
    inStock: _inStock,
    discountedOnly: _discountOnly,
    minRating: _minRating,
  );

  setState(() {
    if (results.length < 20) _hasMore = false;
    if (results.isNotEmpty) _lastDoc = results.last.firestoreSnapshot;
    _products.addAll(results);
    _isLoading = false;
  });
}

  List<String> _selectedCategories = [];
  bool _inStock = false;
bool _discountOnly = false;
double? _minRating;

void _onFilterChanged(
  String? brand,
  double? min,
  double? max,
  List<String> categories, {
  bool? inStock,
  bool? discountedOnly,
  double? minRating,
}) {
  setState(() {
    _brand = brand;
    _minPrice = min;
    _maxPrice = max;
    _selectedCategories = categories;
    _inStock = inStock ?? false;
    _discountOnly = discountedOnly ?? false;
    _minRating = minRating;
    _products.clear();
    _lastDoc = null;
    _hasMore = true;
  });
  _fetchPage();
}

  void _onSortChanged(String sortValue) {
    setState(() {
      _sortBy = SortOptionHelper.fromValue(sortValue);
      _products.clear();
      _lastDoc = null;
      _hasMore = true;
    });
    _fetchPage();
  }

  void _onToggleView(bool isGrid) {
    setState(() => _isGrid = isGrid);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final crossAxisCount =
        screenWidth > 1200
            ? 4
            : screenWidth > 900
            ? 3
            : 2;
    final itemWidth =
        (screenWidth - 32 - ((crossAxisCount - 1) * 16)) / crossAxisCount;
    final itemHeight = 370;
    final aspectRatio = itemWidth / itemHeight;

    return Scaffold(
      drawer: const NavDrawer(),
      appBar: const AppHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 12),
                SearchBarWidget(controller: _searchController),
                FilterPanel(onFilter: _onFilterChanged),
                SortPanel(current: _sortBy, onSort: _onSortChanged),
                ViewToggle(isGrid: _isGrid, onToggle: _onToggleView),
                const SizedBox(height: 12),

                _isLoading
  ? const Padding(
      padding: EdgeInsets.all(16),
      child: CircularProgressIndicator(),
    )
  : _products.isEmpty
    ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Text(
          "No products found. Try changing the filters.",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
        ),
      )
    : _isGrid
        ? GridView.builder(
            padding: const EdgeInsets.only(top: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (_, i) => ProductGridItem(product: _products[i]),
          )
        : ListView.separated(
            padding: const EdgeInsets.only(top: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _products.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (_, i) => ProductListItem(product: _products[i]),
          ),


                const SizedBox(height: 32),
                const FooterWidget(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
