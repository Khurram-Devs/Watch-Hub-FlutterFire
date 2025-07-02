enum SortOption { PriceAsc, PriceDesc, New, Rating }

extension SortOptionHelper on SortOption {
  String get value {
    switch (this) {
      case SortOption.PriceAsc:
        return 'price_asc';
      case SortOption.PriceDesc:
        return 'price_desc';
      case SortOption.Rating:
        return 'rating';
      case SortOption.New:
      default:
        return 'arrival';
    }
  }

  static SortOption fromValue(String value) {
    switch (value) {
      case 'price_asc':
        return SortOption.PriceAsc;
      case 'price_desc':
        return SortOption.PriceDesc;
      case 'rating':
        return SortOption.Rating;
      case 'arrival':
      default:
        return SortOption.New;
    }
  }
}
