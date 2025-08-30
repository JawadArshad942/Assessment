import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/paginated_products.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/search_products.dart';

part 'product_state.dart';

enum ProductSort { bestRating, latest, priceLowToHigh, priceHighToLow }

class ProductCubit extends Cubit<ProductState> {
  ProductCubit({required this.getProducts, required this.searchProducts}) : super(const ProductState.initial());

  final GetProducts getProducts;
  final SearchProducts searchProducts;

  List<ProductEntity> _all = <ProductEntity>[];
  int _skip = 0;
  int _limit = 30;
  int _total = 0;
  bool _isLoadingMore = false;
  ProductSort? _sort;
  num? _minPrice;
  num? _maxPrice;
  String _query = '';

  Future<void> load({int limit = 30}) async {
    emit(const ProductState.loading());
    try {
      _limit = limit;
      final PaginatedProductsEntity page = await getProducts(limit: _limit, skip: 0);
      _all = page.products;
      _skip = page.products.length;
      _total = page.total;
      _emitFiltered();
    } catch (e) {
      emit(ProductState.error(message: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _skip >= _total) return;
    _isLoadingMore = true;
    emit(ProductState.loaded(products: _applyFilters(_all), canLoadMore: true, isLoadingMore: true));
    try {
      final PaginatedProductsEntity page = await getProducts(limit: _limit, skip: _skip);
      _all = <ProductEntity>[..._all, ...page.products];
      _skip += page.products.length;
      _emitFiltered();
    } catch (_) {
      _emitFiltered();
    } finally {
      _isLoadingMore = false;
    }
  }

  void query(String text) {
    _query = text;
    _emitFiltered();
  }

  void setSorting({ProductSort? sort, num? minPrice, num? maxPrice}) {
    _sort = sort;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _emitFiltered();
  }

  void _emitFiltered() {
    emit(ProductState.loaded(products: _applyFilters(_all), canLoadMore: _skip < _total, isLoadingMore: false));
  }

  List<ProductEntity> _applyFilters(List<ProductEntity> base) {
    List<ProductEntity> list = base;
    // search filter
    list = searchProducts(list, _query);
    // price filter
    if (_minPrice != null || _maxPrice != null) {
      list = list.where((ProductEntity p) {
        final num price = p.price;
        final bool minOk = _minPrice == null || price >= _minPrice!;
        final bool maxOk = _maxPrice == null || price <= _maxPrice!;
        return minOk && maxOk;
      }).toList();
    }
    // sorting
    if (_sort != null) {
      list = List<ProductEntity>.from(list);
      switch (_sort!) {
        case ProductSort.bestRating:
          list.sort((ProductEntity a, ProductEntity b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          break;
        case ProductSort.latest:
          list.sort((ProductEntity a, ProductEntity b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
          break;
        case ProductSort.priceLowToHigh:
          list.sort((ProductEntity a, ProductEntity b) => a.price.compareTo(b.price));
          break;
        case ProductSort.priceHighToLow:
          list.sort((ProductEntity a, ProductEntity b) => b.price.compareTo(a.price));
          break;
      }
    }
    return list;
  }
}
