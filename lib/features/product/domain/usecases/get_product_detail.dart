import '../entities/product_detail.dart';
import '../repositories/product_repository.dart';

class GetProductDetail {
  GetProductDetail(this._repository);

  final ProductRepository _repository;

  Future<ProductDetailEntity> call(int id) => _repository.getProductDetail(id);
}
