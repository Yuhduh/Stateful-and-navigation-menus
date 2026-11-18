import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastname_navigation_app/calculator_screen.dart';
import 'package:lastname_navigation_app/demo_auth.dart';
import 'package:lastname_navigation_app/dashboard_page.dart';
import 'package:lastname_navigation_app/login_screen.dart';
import 'package:lastname_navigation_app/main.dart';
import 'package:lastname_navigation_app/social_media/create_post_sheet.dart';
import 'package:lastname_navigation_app/social_media/post_card.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  final target = find.text(text);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> login(
  WidgetTester tester,
  String username,
  String password,
) async {
  await tester.enterText(find.byType(TextFormField).at(0), username);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
    DemoAuth.logout();
  });

  test('Registration replaces the demo account and preserves admin login', () {
    expect(DemoAuth.login('admin', 'admin123'), isTrue);
    expect(DemoAuth.currentUsername, 'admin');
    expect(DemoAuth.login('admin', 'wrong'), isFalse);
    DemoAuth.register('first', 'password1');
    expect(DemoAuth.login('first', 'password1'), isTrue);
    DemoAuth.register('second', 'password2');
    expect(DemoAuth.login('first', 'password1'), isFalse);
    expect(DemoAuth.login('second', 'password2'), isTrue);
    expect(DemoAuth.currentUsername, 'second');
    expect(DemoAuth.login('admin', 'admin123'), isTrue);
    DemoAuth.logout();
    expect(DemoAuth.currentUsername, isNull);
    expect(DemoAuth.login('invalid', 'invalid'), isFalse);
    expect(DemoAuth.currentUsername, isNull);
  });

  testWidgets(
    'Login validates fields, toggles visibility, and rejects bad credentials',
    (tester) async {
      await tester.pumpWidget(const StudentApp());
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(DashboardPage), findsNothing);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your username.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);

      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
        isTrue,
      );
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
        isFalse,
      );

      await login(tester, 'admin', 'wrong');
      expect(find.text('Invalid username or password.'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    },
  );

  testWidgets('Registration validates input and the new account can log in', (
    tester,
  ) async {
    await tester.pumpWidget(const StudentApp());
    await tapText(tester, "Don't have an account? Register");

    Future<void> register() async {
      final button = find.widgetWithText(ElevatedButton, 'Register');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    await register();
    expect(find.text('Use at least 3 characters.'), findsOneWidget);
    expect(find.text('Enter a password.'), findsOneWidget);
    expect(find.text('Confirm your password.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'ADMIN');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.enterText(find.byType(TextFormField).at(2), 'different');
    await register();
    expect(find.text('This username is reserved.'), findsOneWidget);
    expect(find.text('Use at least 6 characters.'), findsOneWidget);
    expect(find.text('Passwords do not match.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '  carl  ');
    await tester.enterText(find.byType(TextFormField).at(1), 'student123');
    await tester.enterText(find.byType(TextFormField).at(2), 'student123');
    await register();
    expect(
      find.text('Registration successful! You can now log in.'),
      findsOneWidget,
    );
    await login(tester, 'carl', 'student123');
    expect(find.text('Welcome, carl!'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('Logged in as: carl'), findsOneWidget);
    expect(find.text('Carl John Paul Masayon'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Create Post'));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(CreatePostSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'A post from my registered account');
    await tester.enterText(fields.at(1), 'https://example.com/student.jpg');
    await tapText(tester, 'Submit Post');
    final post = find.ancestor(
      of: find.text('A post from my registered account'),
      matching: find.byType(PostCard),
    );
    expect(
      find.descendant(of: post, matching: find.text('carl')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Four tabs preserve calculator state and show profile and social feed',
    (tester) async {
      await tester.pumpWidget(const StudentApp());
      await login(tester, 'admin', 'admin123');
      expect(find.text('Welcome, admin!'), findsOneWidget);
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(
        tester
            .widgetList<NavigationDestination>(
              find.byType(NavigationDestination),
            )
            .map((destination) => destination.label),
        ['Dashboard', 'Calculator', 'Social', 'Profile'],
      );

      await tester.tap(find.byIcon(Icons.calculate_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '10');
      await tester.enterText(find.byType(TextField).at(1), '5');
      await tapText(tester, '+');
      expect(find.text('15.0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.text('Carl John Paul Masayon'), findsOneWidget);
      expect(find.text('554004'), findsOneWidget);
      expect(find.text('CCE106L - 3450'), findsOneWidget);
      expect(find.text('c.masayon.554004@umindanao.edu.ph'), findsOneWidget);
      expect(find.text('Logged in as: admin'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.people_outline));
      await tester.pumpAndSettle();
      expect(find.text('JohnDoe'), findsOneWidget);
      expect(find.text('Enjoying the sunny weather!'), findsOneWidget);
      expect(find.byTooltip('Create Post'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.dashboard_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Welcome, admin!'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.calculate_outlined));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
        '10',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        '5',
      );
      expect(find.text('15.0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Calculator handles all operations, invalid input, division by zero, and Clear',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CalculatorScreen()));
      await tapText(tester, '+');
      expect(find.text('Invalid input'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), '20');
      await tester.enterText(find.byType(TextField).at(1), '5');
      for (final operation in {
        '+': '25.0',
        '−': '15.0',
        '×': '100.0',
        '÷': '4.0',
      }.entries) {
        await tapText(tester, operation.key);
        expect(find.text(operation.value), findsOneWidget);
      }

      await tester.enterText(find.byType(TextField).at(0), '12.5');
      await tester.enterText(find.byType(TextField).at(1), '-2');
      for (final operation in {
        '+': '10.5',
        '−': '14.5',
        '×': '-25.0',
        '÷': '-6.25',
      }.entries) {
        await tapText(tester, operation.key);
        expect(find.text(operation.value), findsOneWidget);
      }

      await tester.enterText(find.byType(TextField).at(1), '0');
      await tapText(tester, '÷');
      expect(find.text('Cannot divide by zero'), findsOneWidget);
      for (final invalid in ['abc', 'NaN', 'Infinity']) {
        await tester.enterText(find.byType(TextField).at(0), invalid);
        await tapText(tester, '+');
        expect(find.text('Invalid input'), findsOneWidget);
      }

      await tapText(tester, 'Clear');
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Enter two numbers'), findsOneWidget);
      for (final field in tester.widgetList<TextField>(
        find.byType(TextField),
      )) {
        expect(field.controller!.text, isEmpty);
      }
    },
  );
}
