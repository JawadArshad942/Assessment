import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/product.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../product/presentation/cubit/product_cubit.dart';
import '../cubit/cart_cubit.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductState productState = context.watch<ProductCubit>().state;
    final List<ProductEntity> all = productState.products;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (BuildContext context, CartState state) {
          final List<ProductEntity> items = all.where((ProductEntity p) => state.productIdToQuantity.containsKey(p.id)).toList();

          final Orientation orientation = MediaQuery.of(context).orientation;
          final bool isPortrait = orientation == Orientation.portrait;
          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          num originalSubtotal = 0;
          num discountedSubtotal = 0;
          for (final ProductEntity p in items) {
            final int qty = state.productIdToQuantity[p.id] ?? 0;
            final num discountedUnit = (p.discountPercentage != null && p.discountPercentage! > 0) ? p.price * (1 - (p.discountPercentage! / 100)) : p.price;
            originalSubtotal += p.price * qty;
            discountedSubtotal += discountedUnit * qty;
          }
          final num discountAmount = (originalSubtotal - discountedSubtotal);

          return Column(
            children: <Widget>[
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: isPortrait
                      ? const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: 2.45)
                      : const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.35),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ProductEntity product = items[index];
                    final int qty = state.productIdToQuantity[product.id] ?? 0;
                    final int minQty = product.minimumOrderQuantity ?? 1;
                    final num unit =
                        (product.discountPercentage != null && product.discountPercentage! > 0) ? product.price * (1 - (product.discountPercentage! / 100)) : product.price;
                    return Dismissible(
                      key: ValueKey<int>(product.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => context.read<CartCubit>().removeAll(product),
                      child: Card(
                        child: Row(
                          children: <Widget>[
                            AppCachedImage(url: product.thumbnail, fit: BoxFit.cover, width: 130),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(product.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2),
                                    Row(
                                      children: <Widget>[
                                        Text('\$${unit.toStringAsFixed(2)}'),
                                        if (unit != product.price) ...<Widget>[
                                          const SizedBox(width: 8),
                                          Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(decoration: TextDecoration.lineThrough)),
                                        ],
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        IconButton(
                                          onPressed: (qty <= minQty) ? null : () => context.read<CartCubit>().remove(product),
                                          icon: const Icon(Icons.remove_circle_outline),
                                        ),
                                        Text('$qty'),
                                        IconButton(
                                          onPressed: () => context.read<CartCubit>().add(product),
                                          icon: const Icon(Icons.add_circle_outline),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Items'),
                        Text('${context.read<CartCubit>().totalItems()}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Subtotal'),
                        Text('\$${originalSubtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    if (discountAmount > 0) ...<Widget>[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text('Discount'),
                          Text('\$${discountAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('\$${discountedSubtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: () {}, child: const Text('Checkout')),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
