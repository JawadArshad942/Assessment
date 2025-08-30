import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../domain/entities/product_detail.dart';
import '../cubit/product_detail_cubit.dart';
import '../../../../core/widgets/app_cached_image.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.id});

  final int id;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductDetailCubit>().load(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      bottomNavigationBar: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (BuildContext context, ProductDetailState state) {
          if (state.isLoading) {
            return const SizedBox.shrink();
          }
          if (state.detail == null) {
            return SizedBox.shrink();
          }
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _DetailCartControls(product: state.detail!),
            ),
          );
        },
      ),
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (BuildContext context, ProductDetailState state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.message != null && state.detail == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Failed to load product details", textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => context.read<ProductDetailCubit>().load(widget.id),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state.detail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final ProductDetailEntity d = state.detail!;
          final ThemeData theme = Theme.of(context);
          final bool lowStock = (d.stock ?? 0) > 0 && (d.stock! <= 5);
          return RefreshIndicator(
            onRefresh: () async => context.read<ProductDetailCubit>().load(widget.id),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Hero(
                    tag: 'p_${d.id}',
                    child: PageView(
                      children: d.images.map((String url) => AppCachedImage(url: url, fit: BoxFit.cover)).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(d.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Text('\$${d.price}', style: theme.textTheme.titleMedium),
                    const SizedBox(width: 12),
                    if (d.rating != null) Row(children: <Widget>[const Icon(Icons.star, size: 16), Text('${d.rating}')]),
                    const Spacer(),
                    if (d.availabilityStatus != null) Chip(label: Text(d.availabilityStatus!)),
                  ],
                ),
                const SizedBox(height: 8),
                if (d.stock != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Chip(
                          label: Text('${d.stock} left'),
                          backgroundColor: lowStock ? Colors.red.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                        ),
                        const SizedBox(width: 8),
                        if (state.detail!.minimumOrderQuantity != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Chip(
                              label: Text('Minimum purchase: ${state.detail!.minimumOrderQuantity}'),
                              backgroundColor: Colors.blueGrey.withOpacity(0.12),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Text(d.description),
                const SizedBox(height: 16),
                if (d.brand != null)
                  Wrap(spacing: 8, runSpacing: 8, children: <Widget>[
                    Chip(label: Text('Brand: ${d.brand}')),
                  ]),
                const SizedBox(height: 16),
                if (d.tags.isNotEmpty) Wrap(spacing: 6, runSpacing: 6, children: d.tags.map((String t) => Chip(label: Text(t))).toList()),
                const SizedBox(height: 16),
                if (d.dimensions != null) Text('Dimensions: ${d.dimensions!.width} x ${d.dimensions!.height} x ${d.dimensions!.depth}') else const SizedBox.shrink(),
                const SizedBox(height: 8),
                if (d.weight != null) Text('Weight: ${d.weight}'),
                const SizedBox(height: 16),
                if (d.warrantyInformation != null) Text('Warranty: ${d.warrantyInformation}'),
                if (d.shippingInformation != null) Text('Shipping: ${d.shippingInformation}'),
                if (d.returnPolicy != null) Text('Returns: ${d.returnPolicy}'),
                const SizedBox(height: 16),
                if (d.reviews.isNotEmpty) ...<Widget>[
                  Text('Reviews', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...d.reviews.map(
                    (ReviewEntity r) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_outline),
                      title: Text(r.reviewerName),
                      subtitle: Text(r.comment),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[const Icon(Icons.star, size: 16), Text('${r.rating}')]),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailCartControls extends StatelessWidget {
  const _DetailCartControls({required this.product});

  final ProductDetailEntity product;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (BuildContext context, CartState state) {
        final int id = product.id;
        final int qty = state.productIdToQuantity[id] ?? 0;
        final int minQty = product.minimumOrderQuantity ?? 1;
        final int? stock = product.stock;
        final bool outOfStock = stock != null && stock <= 0;
        final summary = product.toProductSummary();

        if (qty == 0) {
          return FilledButton.icon(
            onPressed: outOfStock ? null : () => serviceLocator<CartCubit>().add(summary),
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(outOfStock ? 'Out of stock' : 'Add to Cart (min $minQty)'),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: (qty <= minQty) ? null : () => serviceLocator<CartCubit>().remove(summary),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                IconButton(
                  onPressed: (stock != null && qty >= stock) ? null : () => serviceLocator<CartCubit>().add(summary),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.push('/cart'),
              child: const Text('View Cart'),
            ),
          ],
        );
      },
    );
  }
}
