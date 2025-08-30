import '../entities/paginated_products.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  GetProducts(this._repository);

  final ProductRepository _repository;

  Future<PaginatedProductsEntity> call({int limit = 30, int skip = 0}) {
    return _repository.getProducts(limit: limit, skip: skip);
  }
}
