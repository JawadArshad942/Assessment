import 'package:hive_flutter/hive_flutter.dart';

import '../models/product_model.dart';
import '../models/product_detail_model.dart';
import '../../domain/entities/product_detail.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> models, {required int total});
  Future<({List<ProductModel> products, int total})> getCachedProducts();
  Future<void> cacheProductDetail(ProductDetailModel model);
  Future<ProductDetailModel?> getCachedProductDetail(int id);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const String _boxName = 'productsBox';
  static const String _productsKey = 'products';
  static const String _totalKey = 'total';
  static const String _detailPrefix = 'detail_';

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

  @override
  Future<void> cacheProductDetail(ProductDetailModel model) async {
    final Box<dynamic> box = Hive.box<dynamic>(_boxName);
    final Map<String, dynamic> json = <String, dynamic>{
      'id': model.id,
      'title': model.title,
      'description': model.description,
      'price': model.price,
      'thumbnail': model.thumbnail,
      'images': model.images,
      'category': model.category,
      'discountPercentage': model.discountPercentage,
      'rating': model.rating,
      'stock': model.stock,
      'tags': model.tags,
      'brand': model.brand,
      'sku': model.sku,
      'weight': model.weight,
      'dimensions': model.dimensions == null ? null : <String, dynamic>{'width': model.dimensions!.width, 'height': model.dimensions!.height, 'depth': model.dimensions!.depth},
      'warrantyInformation': model.warrantyInformation,
      'shippingInformation': model.shippingInformation,
      'availabilityStatus': model.availabilityStatus,
      'reviews': model.reviews
          .map((ReviewEntity r) => <String, dynamic>{
                'rating': r.rating,
                'comment': r.comment,
                'date': r.date.toIso8601String(),
                'reviewerName': r.reviewerName,
                'reviewerEmail': r.reviewerEmail,
              })
          .toList(),
      'returnPolicy': model.returnPolicy,
      'minimumOrderQuantity': model.minimumOrderQuantity,
      'meta': <String, dynamic>{
        'createdAt': model.meta?.createdAt?.toIso8601String(),
        'updatedAt': model.meta?.updatedAt?.toIso8601String(),
        'barcode': model.meta?.barcode,
        'qrCode': model.meta?.qrCode,
      },
    };
    await box.put('$_detailPrefix${model.id}', json);
  }

  @override
  Future<ProductDetailModel?> getCachedProductDetail(int id) async {
    final Box<dynamic> box = Hive.box<dynamic>(_boxName);
    final Map<String, dynamic>? json = (box.get('$_detailPrefix$id') as Map?)?.cast<String, dynamic>();
    if (json == null) return null;
    return ProductDetailModel.fromJson(json);
  }
}
