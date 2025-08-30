import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/cart_local_data_source.dart';
import '../../../product/domain/entities/product.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({required this.local}) : super(const CartState()) {
    _hydrate();
  }

  final CartLocalDataSource local;

  Future<void> _hydrate() async {
    final Map<int, int> q = await local.readQuantities();
    emit(state.copyWith(productIdToQuantity: q));
  }

  Future<void> _persist(Map<int, int> qty) => local.write(qty);

  void add(ProductEntity product) {
    final Map<int, int> qty = Map<int, int>.from(state.productIdToQuantity);
    final int minQty = product.minimumOrderQuantity ?? 1;
    if (qty.containsKey(product.id)) {
      final int current = qty[product.id]!;
      int next = current + 1;
      if (product.stock != null) {
        next = next.clamp(1, product.stock!);
      }
      qty[product.id] = next;
    } else {
      int initial = minQty;
      if (product.stock != null) {
        initial = initial.clamp(1, product.stock!);
      }
      qty[product.id] = initial;
    }
    emit(state.copyWith(productIdToQuantity: qty));
    _persist(qty);
  }

  void remove(ProductEntity product) {
    final Map<int, int> qty = Map<int, int>.from(state.productIdToQuantity);
    if (!qty.containsKey(product.id)) return;
    final int newVal = qty[product.id]! - 1;
    if (newVal <= 0) {
      qty.remove(product.id);
    } else {
      qty[product.id] = newVal;
    }
    emit(state.copyWith(productIdToQuantity: qty));
    _persist(qty);
  }

  void removeAll(ProductEntity product) {
    final Map<int, int> qty = Map<int, int>.from(state.productIdToQuantity);
    if (!qty.containsKey(product.id)) return;
    qty.remove(product.id);
    emit(state.copyWith(productIdToQuantity: qty));
    _persist(qty);
  }

  void setQuantity(ProductEntity product, int quantity) {
    final Map<int, int> qty = Map<int, int>.from(state.productIdToQuantity);
    if (quantity <= 0) {
      qty.remove(product.id);
    } else {
      int val = quantity;
      if (product.minimumOrderQuantity != null) {
        val = val < product.minimumOrderQuantity! ? product.minimumOrderQuantity! : val;
      }
      if (product.stock != null) {
        val = val > product.stock! ? product.stock! : val;
      }
      qty[product.id] = val;
    }
    emit(state.copyWith(productIdToQuantity: qty));
    _persist(qty);
  }

  num total(List<ProductEntity> allProducts) {
    num t = 0;
    for (final MapEntry<int, int> entry in state.productIdToQuantity.entries) {
      final ProductEntity product = allProducts.firstWhere(
        (ProductEntity p) => p.id == entry.key,
        orElse: () => const ProductEntity(
          id: -1,
          title: '',
          description: '',
          price: 0,
          thumbnail: '',
          images: <String>[],
        ),
      );
      if (product.id != -1) {
        final num unitPrice = (product.discountPercentage != null && product.discountPercentage! > 0) ? product.price * (1 - (product.discountPercentage! / 100)) : product.price;
        t += unitPrice * entry.value;
      }
    }
    return t;
  }

  int totalItems() {
    return state.productIdToQuantity.length;
  }
}
