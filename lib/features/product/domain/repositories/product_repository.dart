import '../entities/paginated_products.dart';
import '../entities/product_detail.dart';

abstract class ProductRepository {
  Future<PaginatedProductsEntity> getProducts({int limit = 30, int skip = 0});
  Future<ProductDetailEntity> getProductDetail(int id);
}
