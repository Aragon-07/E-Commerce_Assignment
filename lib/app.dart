import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/review_repository.dart';
import 'data/repositories/wishlist_repository.dart';
import 'data/services/api_client.dart';
import 'data/services/auth_storage.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/view_models/auth_view_model.dart';
import 'ui/view_models/cart_view_model.dart';
import 'ui/view_models/category_view_model.dart';
import 'ui/view_models/home_view_model.dart';
import 'ui/view_models/main_nav_view_model.dart';
import 'ui/view_models/order_view_model.dart';
import 'ui/view_models/wishlist_view_model.dart';

/// Root CraftyBay application widget setting up DI providers and theme.
class CraftyBayApp extends StatelessWidget {
  const CraftyBayApp({
    super.key,
    this.splashDelay = const Duration(milliseconds: 1400),
  });

  final Duration splashDelay;

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final authStorage = AuthStorage();

    final authRepository = AuthRepository(
      apiClient: apiClient,
      authStorage: authStorage,
    );
    final catalogRepository = CatalogRepository(apiClient: apiClient);
    final reviewRepository = ReviewRepository(apiClient: apiClient);
    final cartRepository = CartRepository(apiClient: apiClient);
    final wishlistRepository = WishlistRepository(apiClient: apiClient);
    final orderRepository = OrderRepository(apiClient: apiClient);

    return MultiProvider(
      providers: [
        Provider<CatalogRepository>.value(value: catalogRepository),
        Provider<ReviewRepository>.value(value: reviewRepository),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider(create: (_) => MainNavViewModel()),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(catalogRepository: catalogRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CategoryViewModel(catalogRepository: catalogRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CartViewModel(cartRepository: cartRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              WishlistViewModel(wishlistRepository: wishlistRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderViewModel(orderRepository: orderRepository),
        ),
      ],
      child: MaterialApp(
        title: 'CraftyBay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: SplashScreen(delay: splashDelay),
      ),
    );
  }
}
