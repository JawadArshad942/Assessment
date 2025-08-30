part of 'product_detail_cubit.dart';

class ProductDetailState extends Equatable {
  const ProductDetailState._({this.detail, this.isLoading = false, this.message});

  const ProductDetailState.initial() : this._();
  const ProductDetailState.loading() : this._(isLoading: true);
  const ProductDetailState.loaded(this.detail)
      : isLoading = false,
        message = null;
  const ProductDetailState.error(this.message)
      : isLoading = false,
        detail = null;

  final ProductDetailEntity? detail;
  final bool isLoading;
  final String? message;

  @override
  List<Object?> get props => <Object?>[detail, isLoading, message];
}
