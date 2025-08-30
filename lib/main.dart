import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection_container.dart';
import 'routes/app_router.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/product/presentation/cubit/product_cubit.dart';
import 'core/notifications/local_notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<ProductCubit>(create: (_) => serviceLocator<ProductCubit>()),
          BlocProvider<CartCubit>(create: (_) => serviceLocator<CartCubit>()),
        ],
        child: _LifecycleWrapper(
          child: MaterialApp.router(
            title: 'Shopping Cart',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: true,
            ),
            routerConfig: AppRouter.router,
          ),
        ),
      ),
    );
  }
}

class _LifecycleWrapper extends StatefulWidget {
  const _LifecycleWrapper({required this.child});

  final Widget child;

  @override
  State<_LifecycleWrapper> createState() => _LifecycleWrapperState();
}

class _LifecycleWrapperState extends State<_LifecycleWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    serviceLocator<LocalNotificationsService>().initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      final CartCubit cart = context.read<CartCubit>();
      if (cart.state.productIdToQuantity.isNotEmpty) {
        serviceLocator<LocalNotificationsService>().showCartReminder();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
