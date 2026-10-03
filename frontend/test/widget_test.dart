import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/app/app.dart';
import 'package:linkup/core/services/app_services.dart';
import 'package:linkup/features/community/screens/community_screen.dart';
import 'package:linkup/features/connect/screens/connect_screen.dart';
import 'package:linkup/features/assistant/screens/riko_assistant_screen.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppServices.init();
  });

  testWidgets('Full Interactive Flow: Splash -> Guest Login -> Home -> Explore -> Saved', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AppServices.auth.logout();

    await tester.pumpWidget(const LinkUpApp());
    expect(find.text('LINKUP'), findsOneWidget);
    expect(find.text('Riko'), findsOneWidget);

    // Wait for Splash screen delay to finish
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify Login Screen
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.textContaining('LINKUP'), findsWidgets);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Phone'), findsOneWidget);

    // Tap Explore as Demo Student
    await tester.ensureVisible(find.text('Explore as Demo Student'));
    await tester.tap(find.text('Explore as Demo Student'));
    await tester.pumpAndSettle();

    // Verify Home Screen elements
    expect(find.text('Latest Hackathons'), findsOneWidget);
    expect(find.text('Search opportunities...'), findsOneWidget);

    // Switch to Explore Tab via bottom navigation
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    // Verify Explore Screen
    expect(find.text('Explore'), findsWidgets);
    expect(find.text('Hackathons'), findsWidgets);

    // Switch to Saved Tab
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    // Verify Saved Screen
    expect(find.text('Saved Opportunities'), findsOneWidget);
  });

  testWidgets('Community Flow: Post & Discuss', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AppServices.auth.loginAsGuest();

    await tester.pumpWidget(
      const MaterialApp(
        home: CommunityScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Community'), findsOneWidget);

    // Tap Start Discussion FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Post'), findsOneWidget);

    // Fill new post form
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Automated Test Discussion Title');
    await tester.enterText(textFields.at(1), 'This is an automated test discussion post body content.');
    await tester.pumpAndSettle();

    // Tap Publish
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();

    // Verify newly published post appears in feed
    expect(find.text('Automated Test Discussion Title'), findsOneWidget);
  });

  testWidgets('Connect Flow: Connect with student, Join Group, Request Mentor', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AppServices.auth.loginAsGuest();

    await tester.pumpWidget(
      const MaterialApp(
        home: ConnectScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Connect'), findsOneWidget);

    // Switch to Students filter
    await tester.tap(find.text('Students'));
    await tester.pumpAndSettle();

    // Switch to Communities chip
    await tester.tap(find.text('Communities'));
    await tester.pumpAndSettle();

    // Switch to Mentors chip
    await tester.tap(find.text('Mentors'));
    await tester.pumpAndSettle();
  });

  testWidgets('Profile Flow: View Profile, Open Edit Profile, Save Changes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AppServices.auth.loginAsGuest();

    await tester.pumpWidget(const LinkUpApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Navigate to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Skills & Tech'), findsOneWidget);

    // Open Edit Profile via tooltip
    await tester.tap(find.byTooltip('Edit Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);

    // Edit Name
    final nameField = find.byType(TextFormField).first;
    await tester.enterText(nameField, 'Sandeep B Tech');
    await tester.pumpAndSettle();

    // Tap Save button on AppBar
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify updated profile name appears
    expect(find.text('Sandeep B Tech'), findsWidgets);
  });

  testWidgets('Riko Assistant Screen Flow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AppServices.auth.loginAsGuest();

    await tester.pumpWidget(
      const MaterialApp(
        home: RikoAssistantScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Riko'), findsWidgets);
    expect(find.text('Online Scout'), findsOneWidget);

    // Tap quick suggestion chip
    await tester.tap(find.text('Find cybersecurity hackathons'));
    await tester.pumpAndSettle();

    // Verify Riko response appears
    expect(find.textContaining('cybersecurity'), findsWidgets);
  });

  testWidgets('Theme Switcher & Settings Flow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await AppServices.auth.loginAsGuest();

    await tester.pumpWidget(const LinkUpApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Navigate to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Open Settings via AppBar icon
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings & Preferences'), findsOneWidget);
    expect(find.text('Theme Mode'), findsOneWidget);

    // Verify theme mode changer
    await AppServices.setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(AppServices.themeModeNotifier.value, ThemeMode.dark);

    await AppServices.setThemeMode(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(AppServices.themeModeNotifier.value, ThemeMode.light);
  });
}
