import 'package:dio/dio.dart';

import '../models/product_model.dart';
import '../models/product_detail_model.dart';

abstract class ProductRemoteDataSource {
  Future<({List<ProductModel> products, int total, int skip, int limit})> fetchProducts({int limit = 30, int skip = 0});
  Future<ProductDetailModel> fetchProductDetail(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<({List<ProductModel> products, int total, int skip, int limit})> fetchProducts({int limit = 30, int skip = 0}) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/products',
      queryParameters: <String, dynamic>{'limit': limit, 'skip': skip},
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final List<dynamic> items = body['products'] as List<dynamic>;
    final List<ProductModel> list = items.map((dynamic e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    final int total = body['total'] as int? ?? list.length;
    final int limitResp = body['limit'] as int? ?? limit;
    final int skipResp = body['skip'] as int? ?? skip;
    return (products: list, total: total, skip: skipResp, limit: limitResp);
  }

  @override
  Future<ProductDetailModel> fetchProductDetail(int id) async {
    final Response<dynamic> response = await _dio.get<dynamic>('/products/$id');
    return ProductDetailModel.fromJson(response.data as Map<String, dynamic>);
  }
}
