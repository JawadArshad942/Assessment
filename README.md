## Flutter Shopping Cart (Clean Architecture)

This app demonstrates a responsive shopping cart built with Flutter using Clean Architecture and SOLID principles.

### Tech
- State management: flutter_bloc (Cubit)
- Routing: go_router
- Networking: dio
- DI: get_it
- Local storage: Hive (products and details cache), SharedPreferences (legacy/simple)
- Notifications: flutter_local_notifications

### Project structure
```
lib/
  core/
    network/dio_client.dart
    network/network_info.dart
    network/no_internet_exception.dart
    notifications/local_notifications_service.dart
  features/
    product/
      data/
        datasources/{product_remote_data_source.dart, product_local_data_source.dart}
        models/{product_model.dart, product_detail_model.dart}
        repositories/product_repository_impl.dart
      domain/
        entities/{product.dart, product_detail.dart, paginated_products.dart}
        repositories/product_repository.dart
        usecases/{get_products.dart, get_product_detail.dart, search_products.dart}
      presentation/
        cubit/{product_cubit.dart, product_state.dart, product_detail_cubit.dart, product_detail_state.dart}
        pages/{product_list_page.dart, product_detail_page.dart}
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

### Workflows (Networking, Caching, Fallback)

#### Product List
- First request loads from repository which is cache-first by page slice; otherwise calls remote and caches results.
- Pull-to-refresh triggers a reload. Load-more paginates until `total` is reached.
- Offline handling: if offline and there is cached data for requested slice, it is shown; otherwise an offline retry view is displayed.

Screenshots:

![Products](docs/screenshots/products.png)

#### Product Detail
- Priority 1: cache-first (Hive). If the detail is cached, it is returned immediately.
- Priority 2: remote fetch (when online). On success, detail is cached for subsequent visits.
- Priority 3: argument fallback (UI-only). If offline and no cached detail exists, and the route provides a `ProductDetailEntity` as `extra`, the page renders with that data without caching it.

Screenshots:

![Detail Top](docs/screenshots/detail_top.png)
![Detail Bottom](docs/screenshots/detail_bottom.png)

#### Cart and Pricing
- Unit prices respect discounts; order summary shows Subtotal, Discount, and Total.

Screenshot:

![Cart](docs/screenshots/cart.png)

### Tests
Run unit tests:
```bash
flutter test
```

### Next steps / Improvements
- Add image viewer pinch-zoom gestures on product images.
- Add golden tests and widget tests for UI states.
