import '../../domain/entities/paginated_products.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  @override
  Future<PaginatedProductsEntity> getProducts({int limit = 30, int skip = 0}) async {
    try {
      final result = await remoteDataSource.fetchProducts(limit: limit, skip: skip);
      await localDataSource.cacheProducts(result.products, total: result.total);
      return PaginatedProductsEntity(
        products: result.products.map((e) => e.toEntity()).toList(),
        total: result.total,
        skip: result.skip,
        limit: result.limit,
      );
    } catch (_) {
      // fallback to cache on error
      final cached = await localDataSource.getCachedProducts();
      return PaginatedProductsEntity(
        products: cached.products.map((e) => e.toEntity()).toList(),
        total: cached.total,
        skip: 0,
        limit: cached.products.length,
      );
    }
  }

  @override
  Future<ProductDetailEntity> getProductDetail(int id) async {
    final detail = await remoteDataSource.fetchProductDetail(id);
    return detail.toEntity();
  }
}
