import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../features/cart/presentation/pages/cart_page.dart';
import '../features/product/presentation/pages/product_list_page.dart';
import '../features/product/presentation/pages/product_detail_page.dart';
import '../features/product/presentation/cubit/product_detail_cubit.dart';
import '../features/product/domain/entities/product_detail.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'products',
        pageBuilder: (BuildContext context, GoRouterState state) => const NoTransitionPage(child: ProductListPage()),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'productDetail',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final int id = int.parse(state.pathParameters['id']!);
          final ProductDetailEntity? initial = state.extra is ProductDetailEntity ? state.extra as ProductDetailEntity : null;
          return NoTransitionPage(child: ProductDetailShell(id: id, initial: initial));
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        pageBuilder: (BuildContext context, GoRouterState state) => const NoTransitionPage(child: CartPage()),
      ),
    ],
  );
}

// Shell to provide Cubit for detail page
class ProductDetailShell extends StatelessWidget {
  const ProductDetailShell({super.key, required this.id, this.initial});

  final int id;
  final ProductDetailEntity? initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductDetailCubit>(
      create: (_) => GetIt.I<ProductDetailCubit>(),
      child: ProductDetailPage(id: id, initial: initial),
    );
  }
}
