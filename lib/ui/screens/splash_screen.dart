import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/crafty_bay_logo.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/wishlist_view_model.dart';
import 'main_bottom_nav_screen.dart';

/// Initial splash screen displaying the CraftyBay brand mark and loading session.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.delay = const Duration(milliseconds: 1400),
  });

  final Duration delay;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final authVm = context.read<AuthViewModel>();
    final cartVm = context.read<CartViewModel>();
    final wishlistVm = context.read<WishlistViewModel>();

    await Future.wait([
      authVm.initSession(),
      Future<void>.delayed(widget.delay),
    ]);

    if (authVm.isLoggedIn) {
      await Future.wait([
        cartVm.loadCart(),
        wishlistVm.loadWishlist(),
      ]);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainBottomNavScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: const [
              Spacer(),
              Center(child: CraftyBayLogo()),
              Spacer(),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.8,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Version 1.0',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
