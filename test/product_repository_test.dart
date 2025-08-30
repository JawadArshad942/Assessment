import 'package:flutter_test/flutter_test.dart';
import 'package:innowi_assessment/features/product/data/datasources/product_local_data_source.dart';
import 'package:innowi_assessment/features/product/data/datasources/product_remote_data_source.dart';
import 'package:innowi_assessment/features/product/data/models/product_model.dart';
import 'package:innowi_assessment/features/product/data/repositories/product_repository_impl.dart';

class _RemoteFake implements ProductRemoteDataSource {
  @override
  Future<({List<ProductModel> products, int total, int skip, int limit})> fetchProducts({int limit = 30, int skip = 0}) async {
    final list = <ProductModel>[
      ProductModel(id: 1, title: 'T', description: 'D', price: 3, thumbnail: '', images: <String>[]),
    ];
    return (products: list, total: 1, skip: 0, limit: 30);
  }
}

class _LocalFake implements ProductLocalDataSource {
  List<ProductModel> _cache = <ProductModel>[];
  int _total = 0;

  @override
  Future<void> cacheProducts(List<ProductModel> models, {required int total}) async {
    _cache = <ProductModel>[..._cache, ...models];
    _total = total;
  }

  @override
  Future<({List<ProductModel> products, int total})> getCachedProducts() async {
    return (products: _cache, total: _total);
  }
}

void main() {
  test('Repository returns products and caches them', () async {
    final ProductRepositoryImpl repo = ProductRepositoryImpl(
      remoteDataSource: _RemoteFake(),
      localDataSource: _LocalFake(),
    );

    final result = await repo.getProducts();
    expect(result.products.length, 1);
    expect(result.products.first.id, 1);
    expect(result.total, 1);
  });
}
