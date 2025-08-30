## Flutter Shopping Cart (Clean Architecture)

This app demonstrates a responsive shopping cart built with Flutter using Clean Architecture and SOLID principles.

### Tech
- State management: flutter_bloc (Cubit)
- Routing: go_router
- Networking: dio
- DI: get_it
- Local storage: shared_preferences (simple cache), hive (available to extend)
- Notifications: flutter_local_notifications

### Project structure
```
lib/
  core/
    network/dio_client.dart
    notifications/local_notifications_service.dart
  features/
    product/
      data/
        datasources/{product_remote_data_source.dart, product_local_data_source.dart}
        models/product_model.dart
        repositories/product_repository_impl.dart
      domain/
        entities/product.dart
        repositories/product_repository.dart
        usecases/{get_products.dart, search_products.dart}
      presentation/
        cubit/{product_cubit.dart, product_state.dart}
        pages/product_list_page.dart
    cart/
      presentation/
        cubit/{cart_cubit.dart, cart_state.dart}
        pages/cart_page.dart
  routes/app_router.dart
  injection_container.dart
  main.dart
```

### Setup
1) Install Flutter SDK and run:
```bash
flutter pub get
```

2) Run the app:
```bash
flutter run
```

### Notes
- Products are fetched from `https://dummyjson.com/products` via `dio` and cached in `SharedPreferences`.
- Search is client-side using a use case (`SearchProducts`).
- Layout adapts: list-like in portrait, grid in landscape.
- When the app goes to background with items in cart, a local notification reminds the user.

### Tests
Run unit tests:
```bash
flutter test
```

### Next steps / Improvements
- Replace SharedPreferences with Hive boxes for richer offline data.
- Add pagination and pull-to-refresh for products.
- Add product details page and hero animations.
- Add golden tests and widget tests for UI states.
