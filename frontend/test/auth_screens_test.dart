import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/app/routes.dart';
import 'package:linkup/features/auth/screens/login_screen.dart';
import 'package:linkup/features/auth/screens/phone_login_screen.dart';
import 'package:linkup/features/auth/screens/otp_verification_screen.dart';
import 'package:linkup/core/services/app_services.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppServices.init();
  });

  testWidgets('LoginScreen: Renders visual elements and handles authentication options', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
        routes: {
          AppRoutes.main: (context) => const Scaffold(body: Text('Main Screen')),
          AppRoutes.phoneLogin: (context) => const PhoneLoginScreen(),
        },
      ),
    );

    // Verify visual hierarchy matching reference design
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.textContaining('LINKUP'), findsWidgets);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('OR'), findsOneWidget);
    expect(find.text('Continue with Phone'), findsOneWidget);
    expect(find.text('Explore as Demo Student'), findsOneWidget);

    // Tap Explore as Demo Student
    await tester.ensureVisible(find.text('Explore as Demo Student'));
    await tester.tap(find.text('Explore as Demo Student'));
    await tester.pumpAndSettle();

    expect(find.text('Main Screen'), findsOneWidget);
  });

  testWidgets('PhoneLoginScreen: Renders phone input and navigates on submit', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: const PhoneLoginScreen(),
        routes: {
          AppRoutes.otpVerification: (context) => const Scaffold(body: Text('OTP Verification Screen')),
        },
      ),
    );

    expect(find.text("What's your phone number?"), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);
    expect(find.text('Send Verification Code'), findsOneWidget);

    // Tap submit with empty number -> shows validation message
    await tester.ensureVisible(find.text('Send Verification Code'));
    await tester.tap(find.text('Send Verification Code'));
    await tester.pump();
    expect(find.text('Please enter your phone number.'), findsOneWidget);

    // Enter valid phone number
    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.ensureVisible(find.text('Send Verification Code'));
    await tester.tap(find.text('Send Verification Code'));
    await tester.pumpAndSettle();

    expect(find.text('OTP Verification Screen'), findsOneWidget);
  });

  testWidgets('OtpVerificationScreen: Renders 6 OTP fields and handles verification', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: const OtpVerificationScreen(
          phoneNumber: '+919876543210',
          verificationId: 'mock_verification_id',
        ),
        routes: {
          AppRoutes.main: (context) => const Scaffold(body: Text('Main Screen')),
        },
      ),
    );

    expect(find.text('Verify your number'), findsOneWidget);
    expect(find.text('+919876543210'), findsOneWidget);
    expect(find.text('Verify & Continue'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6));

    // Fill in 6 OTP boxes
    final textFields = find.byType(TextField);
    for (int i = 0; i < 6; i++) {
      await tester.enterText(textFields.at(i), '${i + 1}');
    }

    await tester.ensureVisible(find.text('Verify & Continue'));
    await tester.tap(find.text('Verify & Continue'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Main Screen'), findsOneWidget);
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
            AppRoutes.phoneLogin: (context) => const PhoneLoginScreen(),
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('LINKUP'), findsWidgets);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Phone'), findsOneWidget);
    }
  });
}
