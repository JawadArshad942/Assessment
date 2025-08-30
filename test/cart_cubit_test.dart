import 'package:flutter_test/flutter_test.dart';

import 'package:innowi_assessment/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:innowi_assessment/features/product/domain/entities/product.dart';

void main() {
  group('CartCubit', () {
    test('add, remove, total', () {
      final CartCubit cubit = CartCubit();
      const ProductEntity p = ProductEntity(
        id: 1,
        title: 'A',
        description: 'd',
        price: 10,
        thumbnail: '',
        images: <String>[],
      );

      cubit.add(p);
      cubit.add(p);
      expect(cubit.state.productIdToQuantity[1], 2);

      cubit.remove(p);
      expect(cubit.state.productIdToQuantity[1], 1);

      final num t = cubit.total(const <ProductEntity>[p]);
      expect(t, 10);
    });
  });
}
