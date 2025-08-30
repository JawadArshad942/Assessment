import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_cubit.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().load();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final bool atEnd = _scrollController.position.pixels >= _scrollController.position.maxScrollExtent;
    if (atEnd) {
      context.read<ProductCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: <Widget>[
          BlocBuilder<CartCubit, CartState>(
            builder: (BuildContext context, CartState state) {
              final int count = context.read<CartCubit>().totalItems();
              return GestureDetector(
                onTap: () => context.push('/cart'),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        top: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                          child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _controller,
                onChanged: (String value) => context.read<ProductCubit>().query(value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search products...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductCubit, ProductState>(
                builder: (BuildContext context, ProductState state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.message != null) {
                    return Center(child: Text(state.message!));
                  }

                  final Orientation orientation = MediaQuery.of(context).orientation;
                  final bool isPortrait = orientation == Orientation.portrait;
                  final SliverGridDelegate delegate = isPortrait
                      ? const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: 2.2)
                      : const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.15);

                  return Column(
                    children: <Widget>[
                      Expanded(
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          gridDelegate: delegate,
                          itemCount: state.products.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ProductEntity product = state.products[index];
                            final num? discount = product.discountPercentage;
                            final num price = product.price;
                            final num finalPrice = (discount != null && discount > 0) ? (price * (1 - (discount / 100))) : price;
                            return InkWell(
                              onTap: () => context.push('/product/${product.id}'),
                              child: Card(
                                clipBehavior: Clip.hardEdge,
                                child: Row(
                                  children: <Widget>[
                                    Stack(
                                      children: [
                                        Hero(
                                          tag: 'p_${product.id}',
                                          child: Image.network(product.thumbnail, fit: BoxFit.cover, width: 130),
                                        ),
                                        if (product.rating != null)
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: Colors.green.withOpacity(0.5), borderRadius: BorderRadius.circular(4)),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.star, size: 16, color: Colors.yellow),
                                                    Text('${product.rating?.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodySmall),
                                                  ],
                                                )),
                                          ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              product.title,
                                              style: Theme.of(context).textTheme.titleMedium,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: <Widget>[
                                                Text('\$${finalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleSmall),
                                                if (discount != null && discount > 0) ...<Widget>[
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '\$${price.toStringAsFixed(2)}',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          decoration: TextDecoration.lineThrough,
                                                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                                        ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text('${discount.toStringAsFixed(0)}%'),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              spacing: 12,
                                              runSpacing: 6,
                                              children: <Widget>[
                                                if (product.stock != null)
                                                  Chip(
                                                    label: Text(product.stock! > 0 ? '${product.stock} left' : 'Out of stock'),
                                                    backgroundColor: (product.stock! > 0) ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                                  ),
                                                if (product.minimumOrderQuantity != null)
                                                  Chip(
                                                    label: Text('Min ${product.minimumOrderQuantity}'),
                                                    backgroundColor: Colors.blueGrey.withOpacity(0.12),
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
                      if (state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
