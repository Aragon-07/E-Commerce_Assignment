import 'package:crafty_bay/app.dart';
import 'package:crafty_bay/core/theme/app_theme.dart';
import 'package:crafty_bay/core/widgets/product_card.dart';
import 'package:crafty_bay/core/widgets/quantity_stepper.dart';
import 'package:crafty_bay/data/repositories/auth_repository.dart';
import 'package:crafty_bay/data/services/api_client.dart';
import 'package:crafty_bay/data/services/auth_storage.dart';
import 'package:crafty_bay/ui/screens/auth/login_screen.dart';
import 'package:crafty_bay/ui/screens/auth/otp_verification_screen.dart';
import 'package:crafty_bay/ui/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CraftyBayApp renders SplashScreen brand and version', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const CraftyBayApp(splashDelay: Duration.zero),
    );

    expect(find.text('Version 1.0'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Flush splash timer & frame transitions cleanly.
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('ProductCard displays title, price, rating, and triggers callbacks', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    bool wishTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SizedBox(
            height: 200,
            child: ProductCard(
              title: 'New Year Special Shoe',
              price: 100,
              rating: 4.8,
              onTap: () => tapped = true,
              onActionTap: () => wishTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('New Year Special Shoe'), findsOneWidget);
    expect(find.text('\$100'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);

    await tester.tap(find.text('New Year Special Shoe'));
    expect(tapped, isTrue);

    await tester.tap(find.byIcon(Icons.favorite_border));
    expect(wishTapped, isTrue);
  });

  testWidgets('QuantityStepper formats zero-padded count and handles taps', (
    WidgetTester tester,
  ) async {
    int qty = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: QuantityStepper(
                quantity: qty,
                onIncrement: () => setState(() => qty++),
                onDecrement: () => setState(() => qty--),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('01'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('02'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('01'), findsOneWidget);
  });

  testWidgets('LoginScreen validates empty email and password', (
    WidgetTester tester,
  ) async {
    final authVm = AuthViewModel(
      authRepository: AuthRepository(
        apiClient: ApiClient(),
        authStorage: AuthStorage(),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authVm,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Please enter your email address'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('OtpVerificationScreen renders 4 digit fields and countdown', (
    WidgetTester tester,
  ) async {
    final authVm = AuthViewModel(
      authRepository: AuthRepository(
        apiClient: ApiClient(),
        authStorage: AuthStorage(),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authVm,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OtpVerificationScreen(email: 'test@example.com'),
        ),
      ),
    );

    expect(find.text('Enter OTP Code'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('Resend Code'), findsOneWidget);
  });
}
