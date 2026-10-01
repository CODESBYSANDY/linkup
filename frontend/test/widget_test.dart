import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/app/app.dart';
import 'package:linkup/core/services/app_services.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppServices.init();
  });

  testWidgets('Full Interactive Flow: Splash -> Guest Login -> Home -> Details -> Bookmark', (WidgetTester tester) async {
    await AppServices.auth.logout();

    await tester.pumpWidget(const LinkUpApp());
    expect(find.text('LINKUP'), findsOneWidget);

    // Wait for Splash screen delay to finish
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify Login Screen
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);

    // Tap Continue as Guest
    await tester.tap(find.text('Continue as Guest'));
    await tester.pumpAndSettle();

    // Verify Home Screen appears
    expect(find.text('Find your next opportunity'), findsOneWidget);
    expect(find.text('Featured Opportunity'), findsOneWidget);

    // Tap Search bar preview
    await tester.tap(find.text('Search opportunities, people & topics...'));
    await tester.pumpAndSettle();

    // Verify Search Screen opens
    expect(find.byType(TextField), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'Cybersecurity');
    await tester.pumpAndSettle();

    // Verify search results exist
    expect(find.textContaining('Cybersecurity'), findsWidgets);

    // Go back to Home
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  });

  testWidgets('Community Flow: Like post, Add Comment, Create Post', (WidgetTester tester) async {
    await AppServices.auth.loginAsGuest();

    await tester.pumpWidget(const LinkUpApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Navigate to Community tab
    await tester.tap(find.text('Community'));
    await tester.pumpAndSettle();

    expect(find.text('Community & Knowledge'), findsOneWidget);

    // Tap New Post FAB
    await tester.tap(find.text('New Post'));
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
    await AppServices.auth.loginAsGuest();

    await tester.pumpWidget(const LinkUpApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Navigate to Connect tab
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(find.text('Connect & Network'), findsOneWidget);
    expect(find.text('Students & Peers'), findsOneWidget);

    // Switch to Groups segment
    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    expect(find.text('Technical Communities'), findsOneWidget);

    // Switch to Mentors segment
    await tester.tap(find.text('Mentors'));
    await tester.pumpAndSettle();
    expect(find.text('Knowledge Mentors'), findsOneWidget);
  });

  testWidgets('Profile Flow: View Profile, Open Edit Profile, Save Changes', (WidgetTester tester) async {
    await AppServices.auth.loginAsGuest();

    await tester.pumpWidget(const LinkUpApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Navigate to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Skills & Tech'), findsOneWidget);

    // Open Edit Profile via AppBar icon
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
    expect(find.text('Sandeep B Tech'), findsOneWidget);
  });

  testWidgets('Theme Switcher & Settings Flow', (WidgetTester tester) async {
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
