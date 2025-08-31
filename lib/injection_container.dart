import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/notifications/local_notifications_service.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/cart/data/datasources/cart_local_data_source.dart';
import 'features/product/data/datasources/product_local_data_source.dart';
import 'features/product/data/datasources/product_remote_data_source.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/domain/usecases/get_products.dart';
import 'features/product/domain/usecases/search_products.dart';
import 'features/product/presentation/cubit/product_cubit.dart';
import 'features/product/domain/usecases/get_product_detail.dart';
import 'features/product/presentation/cubit/product_detail_cubit.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Core
  serviceLocator.registerLazySingleton<Dio>(() => createDioClient());
  serviceLocator.registerLazySingleton<NetworkInfo>(() => const NetworkInfoImpl());
  serviceLocator.registerLazySingleton<LocalNotificationsService>(
    () => LocalNotificationsService(),
  );
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('productsBox');
  await Hive.openBox<dynamic>('cartBox');

  // Data sources
  serviceLocator.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(serviceLocator<Dio>()),
  );
  serviceLocator.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(),
  );

  // Repository
  serviceLocator.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: serviceLocator<ProductRemoteDataSource>(),
      localDataSource: serviceLocator<ProductLocalDataSource>(),
      networkInfo: serviceLocator<NetworkInfo>(),
    ),
  );

  // Use cases
  serviceLocator.registerFactory<GetProducts>(() => GetProducts(serviceLocator<ProductRepository>()));
  serviceLocator.registerFactory<SearchProducts>(() => SearchProducts());
  serviceLocator.registerFactory<GetProductDetail>(() => GetProductDetail(serviceLocator<ProductRepository>()));

  // Cubits
  serviceLocator.registerFactory<ProductCubit>(
    () => ProductCubit(
      getProducts: serviceLocator<GetProducts>(),
      searchProducts: serviceLocator<SearchProducts>(),
    ),
  );
  serviceLocator.registerLazySingleton<CartLocalDataSource>(() => CartLocalDataSource());
  serviceLocator.registerLazySingleton<CartCubit>(() => CartCubit(local: serviceLocator<CartLocalDataSource>()));
  serviceLocator.registerFactory<ProductDetailCubit>(
    () => ProductDetailCubit(serviceLocator<GetProductDetail>()),
  );
}
