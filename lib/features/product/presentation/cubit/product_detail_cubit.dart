import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_detail.dart';
import '../../domain/usecases/get_product_detail.dart';

part 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(this._getDetail) : super(const ProductDetailState.initial());

  final GetProductDetail _getDetail;

  Future<void> load(int id) async {
    emit(const ProductDetailState.loading());
    try {
      final ProductDetailEntity detail = await _getDetail(id);
      emit(ProductDetailState.loaded(detail));
    } catch (e) {
      emit(ProductDetailState.error(e.toString()));
    }
  }
}
