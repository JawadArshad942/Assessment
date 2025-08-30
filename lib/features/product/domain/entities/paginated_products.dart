import 'product.dart';

class PaginatedProductsEntity {
  const PaginatedProductsEntity({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<ProductEntity> products;
  final int total;
  final int skip;
  final int limit;
}
