import 'dart:math' as math;
import '../../domain/entities/paginated_products.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/network/no_internet_exception.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<PaginatedProductsEntity> getProducts({int limit = 30, int skip = 0}) async {
    // Serve from cache when requested range is already cached
    final cached = await localDataSource.getCachedProducts();
    final int cachedCount = cached.products.length;
    if (cachedCount > 0 && skip < cachedCount) {
      final int end = math.min(skip + limit, cachedCount);
      final slice = cached.products.sublist(skip, end);
      return PaginatedProductsEntity(
        products: slice.map((e) => e.toEntity()).toList(),
        total: cached.total,
        skip: skip,
        limit: limit,
      );
    }

    // Otherwise fetch remotely and cache (only if online)
    final bool online = await networkInfo.isConnected;
    try {
      if (!online) {
        throw NoInternetException();
      }
      final result = await remoteDataSource.fetchProducts(limit: limit, skip: skip);
      await localDataSource.cacheProducts(result.products, total: result.total);
      return PaginatedProductsEntity(
        products: result.products.map((e) => e.toEntity()).toList(),
        total: result.total,
        skip: result.skip,
        limit: result.limit,
      );
    } catch (e, s) {
      print('error from getProducts from impl: $e \n $s');
      if (e is NoInternetException) rethrow;
      // Fallback to whatever cache exists
      return PaginatedProductsEntity(
        products: <ProductEntity>[],
        total: cached.total,
        skip: skip,
        limit: limit,
      );
    }
  }

  @override
  Future<ProductDetailEntity> getProductDetail(int id) async {
    // Try cache first
    final cached = await localDataSource.getCachedProductDetail(id);
    if (cached != null) {
      return cached.toEntity();
    }

    // If not cached, fetch if online, then cache
    final bool online = await networkInfo.isConnected;
    if (!online) {
      throw NoInternetException();
    }
    final detail = await remoteDataSource.fetchProductDetail(id);
    await localDataSource.cacheProductDetail(detail);
    return detail.toEntity();
  }
}
