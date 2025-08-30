import '../entities/product.dart';

class SearchProducts {
  List<ProductEntity> call(List<ProductEntity> allProducts, String query) {
    final String trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return allProducts;
    return allProducts.where((ProductEntity p) => p.title.toLowerCase().contains(trimmed) || p.description.toLowerCase().contains(trimmed)).toList();
  }
}
