import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/app/routes.dart';
import 'package:linkup/features/auth/screens/login_screen.dart';
import 'package:linkup/features/auth/screens/register_screen.dart';
import 'package:linkup/core/services/app_services.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppServices.init();
  });

  testWidgets('LoginScreen: Renders visual elements and handles login', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
        routes: {
          AppRoutes.main: (context) => const Scaffold(body: Text('Main Screen')),
          AppRoutes.register: (context) => const RegisterScreen(),
        },
      ),
    );

    // Verify visual hierarchy
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue exploring opportunities\nwith Riko.'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('or continue with'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);

    // Tap Sign In
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Main Screen'), findsOneWidget);
  });

  testWidgets('RegisterScreen: Renders visual elements and validates fields', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: const RegisterScreen(),
        routes: {
          AppRoutes.profileSetup: (context) => const Scaffold(body: Text('Profile Setup Screen')),
        },
      ),
    );

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('Create account'), findsOneWidget);

    // Tap submit with empty fields -> shows validation SnackBar
    await tester.tap(find.text('Create account'));
    await tester.pump();
    expect(find.text('Please fill out all registration fields.'), findsOneWidget);

    // Enter valid details across the 4 text fields
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Alex Student');
    await tester.enterText(fields.at(1), 'alex@student.edu');
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'password123');

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Profile Setup Screen'), findsOneWidget);
  });

  testWidgets('Responsive: Renders smoothly across mobile sizes without overflow', (tester) async {
    final deviceSizes = [
      const Size(360, 800),
      const Size(375, 812),
      const Size(390, 844),
      const Size(393, 852),
      const Size(412, 915),
      const Size(430, 932),
    ];

    for (final size in deviceSizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
          routes: {
            AppRoutes.register: (context) => const RegisterScreen(),
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    }
  });
}
