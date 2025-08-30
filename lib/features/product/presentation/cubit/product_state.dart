part of 'product_cubit.dart';

class ProductState extends Equatable {
  const ProductState._({
    this.products = const <ProductEntity>[],
    this.isLoading = false,
    this.message,
    this.canLoadMore = false,
    this.isLoadingMore = false,
    this.noInternet = false,
  });

  const ProductState.initial() : this._();
  const ProductState.loading() : this._(isLoading: true);
  const ProductState.loaded({
    required List<ProductEntity> products,
    bool canLoadMore = false,
    bool isLoadingMore = false,
  }) : this._(products: products, canLoadMore: canLoadMore, isLoadingMore: isLoadingMore);
  const ProductState.error({required String message, bool noInternet = false}) : this._(message: message, noInternet: noInternet);

  final List<ProductEntity> products;
  final bool isLoading;
  final String? message;
  final bool canLoadMore;
  final bool isLoadingMore;
  final bool noInternet;

  @override
  List<Object?> get props => <Object?>[products, isLoading, message, canLoadMore, isLoadingMore, noInternet];
}
