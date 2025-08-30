import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_detail.dart';
import '../../../../core/network/no_internet_exception.dart';
import '../../domain/usecases/get_product_detail.dart';

part 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(this._getDetail) : super(const ProductDetailState.initial());

  final GetProductDetail _getDetail;

  Future<void> load(int id, {ProductDetailEntity? fallback}) async {
    emit(const ProductDetailState.loading());
    try {
      // Repository handles cache-first, then remote+cache
      final ProductDetailEntity detail = await _getDetail(id);
      emit(ProductDetailState.loaded(detail));
    } catch (e) {
      // If offline and a fallback was provided, use it as last resort (not cached)
      if (e is NoInternetException && fallback != null) {
        emit(ProductDetailState.loaded(fallback));
        return;
      }
      emit(ProductDetailState.error(e.toString()));
    }
  }
}
