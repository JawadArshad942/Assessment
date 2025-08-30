import 'package:hive_flutter/hive_flutter.dart';

import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> models, {required int total});
  Future<({List<ProductModel> products, int total})> getCachedProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const String _boxName = 'productsBox';
  static const String _productsKey = 'products';
  static const String _totalKey = 'total';

  @override
  Future<void> cacheProducts(List<ProductModel> models, {required int total}) async {
    final Box<dynamic> box = Hive.box<dynamic>(_boxName);
    final List<Map<String, dynamic>> jsonList = models
        .map((ProductModel m) => <String, dynamic>{
              'id': m.id,
              'title': m.title,
              'description': m.description,
              'price': m.price,
              'thumbnail': m.thumbnail,
              'images': m.images,
              'discountPercentage': m.discountPercentage,
              'rating': m.rating,
              'stock': m.stock,
              'minimumOrderQuantity': m.minimumOrderQuantity,
              'meta': <String, dynamic>{
                'createdAt': m.createdAt?.toIso8601String(),
              },
            })
        .toList();
    // Merge with existing cache
    final List<dynamic> existing = (box.get(_productsKey) as List<dynamic>?) ?? <dynamic>[];
    final List<Map<String, dynamic>> merged = <Map<String, dynamic>>[...existing.cast<Map<String, dynamic>>(), ...jsonList];
    // Deduplicate by id
    final Map<int, Map<String, dynamic>> byId = <int, Map<String, dynamic>>{};
    for (final Map<String, dynamic> p in merged) {
      byId[p['id'] as int] = p;
    }
    box.put(_productsKey, byId.values.toList());
    box.put(_totalKey, total);
  }

  @override
  Future<({List<ProductModel> products, int total})> getCachedProducts() async {
    final Box<dynamic> box = Hive.box<dynamic>(_boxName);
    final List<dynamic> items = (box.get(_productsKey) as List<dynamic>?) ?? <dynamic>[];
    final int total = (box.get(_totalKey) as int?) ?? 0;
    final List<ProductModel> products = items.map((dynamic e) => ProductModel.fromJson((e as Map).cast<String, dynamic>())).toList();
    return (products: products, total: total);
  }
}
